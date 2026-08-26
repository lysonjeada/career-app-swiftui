//
//  AuthenticatedHTTPClient.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation

actor AuthenticatedHTTPClient {
    static let shared =
        AuthenticatedHTTPClient()

    private let authService:
        AuthenticationServiceProtocol

    private var refreshTask:
        Task<String, Error>?

    private init(
        authService:
            AuthenticationServiceProtocol =
            AuthenticationService()
    ) {
        self.authService =
            authService
    }

    func data(
        for request: URLRequest
    ) async throws
        -> (Data, URLResponse) {

        let accessToken =
            try await validAccessToken()

        var authorizedRequest =
            request

        // O backend não manda Cache-Control/Vary nessas rotas, e o
        // URLCache do iOS cacheia por URL só — ignora o header
        // Authorization. Sem isso, a mesma URL de detalhe (ex.: um
        // artigo) fica presa na resposta cacheada de antes de
        // favoritar, mesmo com o servidor já respondendo certo.
        authorizedRequest.cachePolicy =
            .reloadIgnoringLocalCacheData

        authorizedRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        var result =
            try await URLSession.shared
                .data(
                    for:
                        authorizedRequest
                )

        guard let response =
                result.1
                    as? HTTPURLResponse
        else {
            return result
        }

        guard response.statusCode == 401
        else {
            return result
        }

        print(
            """
            🔄 Access token rejeitado.
            Tentando renovar a sessão...
            """
        )

        let newAccessToken =
            try await forceRefresh()

        authorizedRequest.setValue(
            "Bearer \(newAccessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        result =
            try await URLSession.shared
                .data(
                    for:
                        authorizedRequest
                )

        return result
    }
    
    private func validAccessToken()
        async throws -> String {

        if let accessToken =
                AuthSession.shared
                    .accessToken,
           !accessToken.isEmpty {

            return accessToken
        }

        print(
            """
            ⚠️ Access token ausente.
            Tentando recuperar sessão
            usando refresh token...
            """
        )

        return try await forceRefresh()
    }
    
    private func forceRefresh()
        async throws -> String {

        if let refreshTask {
            return try await
                refreshTask.value
        }

        let task =
            Task<String, Error> {

                guard let refreshToken =
                        AuthSession.shared
                            .refreshToken,
                      !refreshToken
                        .isEmpty
                else {
                    throw URLError(
                        .userAuthenticationRequired
                    )
                }

                print(
                    """
                    🔄 Renovando sessão...
                    """
                )

                do {
                    let response =
                        try await authService
                            .refreshToken(
                                refreshToken:
                                    refreshToken
                            )

                    AuthSession.shared
                        .saveTokens(
                            accessToken:
                                response.accessToken,
                            refreshToken:
                                response.refreshToken
                        )

                    print(
                        """
                        ✅ Sessão renovada.
                        """
                    )

                    return response
                        .accessToken

                } catch {
                    print(
                        """
                        ❌ Não foi possível
                        renovar a sessão:

                        \(error)
                        """
                    )

                    AuthSession.shared
                        .clear()

                    throw error
                }
            }

        refreshTask =
            task

        do {
            let accessToken =
                try await task.value

            refreshTask =
                nil

            return accessToken

        } catch {
            refreshTask =
                nil

            throw error
        }
    }
    
    func upload(
        for request: URLRequest,
        fromFile fileURL: URL
    ) async throws
        -> (Data, URLResponse) {

        let accessToken =
            try await validAccessToken()

        var authorizedRequest =
            request

        authorizedRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        var result =
            try await URLSession.shared
                .upload(
                    for:
                        authorizedRequest,
                    fromFile:
                        fileURL
                )

        guard let response =
                result.1
                    as? HTTPURLResponse
        else {
            return result
        }

        guard response.statusCode == 401
        else {
            return result
        }

        print(
            """
            🔄 Upload recebeu 401.
            Renovando sessão...
            """
        )

        let newAccessToken =
            try await forceRefresh()

        authorizedRequest.setValue(
            "Bearer \(newAccessToken)",
            forHTTPHeaderField:
                "Authorization"
        )

        result =
            try await URLSession.shared
                .upload(
                    for:
                        authorizedRequest,
                    fromFile:
                        fileURL
                )

        return result
    }
}
