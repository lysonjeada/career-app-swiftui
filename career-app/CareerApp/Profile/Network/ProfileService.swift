//
//  ProfileService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(userId: String) async throws -> AuthenticationUserResponse
    func deleteUser(userId: String) async throws
}

final class ProfileService:
    ProfileServiceProtocol {

    func fetchProfile(
        userId: String
    ) async throws
        -> AuthenticationUserResponse {

        let normalizedUserId =
            userId.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedUserId.isEmpty
        else {
            throw URLError(.badURL)
        }

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/users/\(normalizedUserId)
                """
        ) else {
            throw URLError(.badURL)
        }

        print(
            """
            🌐 Buscando perfil:
            \(url.absoluteString)
            """
        )

        var request =
            URLRequest(url: url)

        request.httpMethod = "GET"

        request.timeoutInterval = 30

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        if let token =
            AuthSession.shared.accessToken {

            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField:
                    "Authorization"
            )
        }

        let responseData: Data
        let response: URLResponse

        do {
            (
                responseData,
                response
            ) = try await URLSession.shared.data(
                for: request
            )

        } catch {
            print(
                """
                ❌ Erro de rede ao carregar perfil:
                \(error)
                """
            )

            throw error
        }

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw AuthenticationServiceError
                .invalidResponse
        }

        print(
            """
            ✅ Código de resposta (GET Profile):
            \(httpResponse.statusCode)
            """
        )

        if let rawResponse = String(
            data: responseData,
            encoding: .utf8
        ) {
            print(
                """
                📦 Resposta bruta do Profile:
                \(rawResponse)
                """
            )
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            var errorMessage: String?

            if let errorResponse =
                try? JSONDecoder().decode(
                    ErrorResponse.self,
                    from: responseData
                ) {

                errorMessage =
                    errorResponse.detail

            } else if let rawString =
                        String(
                            data: responseData,
                            encoding: .utf8
                        ),
                      !rawString.isEmpty {

                errorMessage =
                    rawString
            }

            throw AuthenticationServiceError
                .badStatusCode(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        errorMessage
                )
        }

        do {
            let decoder =
                JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            let user =
                try decoder.decode(
                    AuthenticationUserResponse.self,
                    from: responseData
                )

            print(
                """
                📥 Perfil decodificado:
                \(user)
                """
            )

            return user

        } catch {
            print(
                """
                ❌ Erro ao decodificar Profile:
                \(error)
                """
            )

            if let responseBody = String(
                data: responseData,
                encoding: .utf8
            ) {
                print(
                    """
                    📦 Corpo recebido:
                    \(responseBody)
                    """
                )
            }

            throw AuthenticationServiceError
                .decodingError(error)
        }
    }
}

extension ProfileService {
    func deleteUser(
        userId: String
    ) async throws {
        let normalizedUserId =
            userId.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedUserId.isEmpty else {
            throw ProfileDeletionServiceError
                .invalidUserId
        }

        guard let baseURL = URL(
            string: APIConstants.pythonURL
        ) else {
            throw ProfileDeletionServiceError
                .invalidURL
        }

        let url = baseURL
            .appendingPathComponent("users")
            .appendingPathComponent(
                normalizedUserId
            )

        var request = URLRequest(url: url)

        request.httpMethod = "DELETE"
        request.timeoutInterval = 60

        print(
            "🗑️ Excluindo usuário:",
            url.absoluteString
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw ProfileDeletionServiceError
                .invalidResponse
        }

        print(
            "📥 Status da exclusão:",
            httpResponse.statusCode
        )

        guard 200..<300 ~= httpResponse.statusCode
        else {
            let message =
                Self.extractDeletionError(
                    from: data
                )

            throw ProfileDeletionServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message: message
                )
        }

        /*
         O backend retorna 204 No Content.
         Portanto, não tente decodificar data.
         */
    }

    private static func extractDeletionError(
        from data: Data
    ) -> String? {
        if let response =
            try? JSONDecoder().decode(
                ProfileDeletionErrorResponse.self,
                from: data
            ) {
            return response.detail
        }

        guard !data.isEmpty else {
            return nil
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }
}

private struct ProfileDeletionErrorResponse:
    Decodable {

    let detail: String
}

private enum ProfileDeletionServiceError:
    LocalizedError {

    case invalidURL
    case invalidUserId
    case invalidResponse

    case serverError(
        statusCode: Int,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return """
            A URL usada para excluir
            a conta é inválida.
            """

        case .invalidUserId:
            return """
            Não foi possível identificar
            o usuário.
            """

        case .invalidResponse:
            return """
            O servidor retornou
            uma resposta inválida.
            """

        case let .serverError(
            statusCode,
            message
        ):
            if let message,
               !message.isEmpty {
                return message
            }

            return """
            Não foi possível excluir
            a conta. Erro \(statusCode).
            """
        }
    }
}
