//
//  ProfileService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(userId: String) async throws -> AuthenticationLoginResponse
    func deleteUser(userId: String) async throws
}

class ProfileService: ProfileServiceProtocol {
    func fetchProfile(userId: String) async throws -> AuthenticationLoginResponse {
        guard let url = URL(string: "\(APIConstants.pythonURL)/users/\(userId)/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationServiceError.invalidResponse
        }
        
        print("✅ Código de resposta (GET Profile): \(httpResponse.statusCode)")
        
        // --- VERIFICAÇÃO DO CÓDIGO DE STATUS PARA LOGIN (200 OK) ---
        guard httpResponse.statusCode == 200 else { // Espera 200 para login bem-sucedido
            var errorMessage: String? = nil
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: responseData) {
                errorMessage = errorResponse.detail
            } else if let rawString = String(data: responseData, encoding: .utf8), !rawString.isEmpty {
                errorMessage = rawString
            }
            throw AuthenticationServiceError.badStatusCode(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Se chegou aqui, o status é 200 OK, então tente decodificar os dados do usuário
        do {
            let loggedInUser = try JSONDecoder().decode(AuthenticationLoginResponse.self, from: responseData)
            print("📥 Resposta do servidor (Profile Sucesso):")
            print(loggedInUser)
            return loggedInUser
        } catch {
            print("❌ Erro ao decodificar resposta de sucesso do profile: \(error.localizedDescription)")
            // Tenta logar o corpo da resposta bruta para depuração
            if let responseBody = String(data: responseData, encoding: .utf8) {
                print("Raw Response Body: \(responseBody)")
            }
            throw AuthenticationServiceError.decodingError(error)
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
