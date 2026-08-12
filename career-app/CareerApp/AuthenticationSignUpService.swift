//
//  AuthenticationSignUpService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func createRegister(
        requestBody: AuthenticationRegisterRequest
    ) async throws -> AuthenticationRegisterResponse

    func fetchLogin(
        requestBody: AuthenticationLoginRequest
    ) async throws -> AuthenticationLoginResponse
}

enum AuthenticationServiceError: LocalizedError {
    case invalidURL
    case invalidResponse

    case emailNotVerified(
        email: String,
        message: String
    )

    case badStatusCode(
        statusCode: Int,
        message: String?
    )

    case decodingError(Error)
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL de autenticação é inválida."

        case .invalidResponse:
            return "Resposta inválida do servidor."

        case let .emailNotVerified(_, message):
            return message

        case let .badStatusCode(
            statusCode,
            message
        ):
            if let message,
               !message.isEmpty {
                return message
            }

            return (
                """
                O servidor retornou o 
                "código \(statusCode).
                """
            )

        case let .decodingError(error):
            return (
                """
                Erro ao interpretar a resposta: 
                \(error.localizedDescription)
                """
            )

        case .unknownError:
            return "Ocorreu um erro desconhecido."
        }
    }
}

// MARK: - Authentication service

final class AuthenticationService:
    AuthenticationServiceProtocol {

    func createRegister(
        requestBody: AuthenticationRegisterRequest
    ) async throws -> AuthenticationRegisterResponse {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)/users/register"
        ) else {
            throw AuthenticationServiceError.invalidURL
        }

        let requestData: Data

        do {
            requestData = try JSONEncoder().encode(
                requestBody
            )
        } catch {
            throw AuthenticationServiceError
                .unknownError
        }

        if let jsonString = String(
            data: requestData,
            encoding: .utf8
        ) {
            print("📤 Corpo da requisição JSON:")
            print(jsonString)
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = requestData

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
            throw error
        }

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw AuthenticationServiceError
                .invalidResponse
        }

        print(
            "✅ Código de resposta (Cadastro):",
            httpResponse.statusCode
        )

        guard 200..<300 ~= httpResponse.statusCode else {
            throw makeStatusCodeError(
                statusCode: httpResponse.statusCode,
                data: responseData
            )
        }

        if let responseBody = String(
            data: responseData,
            encoding: .utf8
        ) {
            print("📥 Resposta do servidor:")
            print(responseBody)
        }

        do {
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            return try decoder.decode(
                AuthenticationRegisterResponse.self,
                from: responseData
            )
        } catch {
            print(
                "❌ Erro ao decodificar cadastro:",
                error
            )

            throw AuthenticationServiceError
                .decodingError(error)
        }
    }

    func fetchLogin(
        requestBody: AuthenticationLoginRequest
    ) async throws -> AuthenticationLoginResponse {
        let urlString =
            "\(APIConstants.pythonURL)/users/login/"

        print(
            "🌐 URL de login:",
            urlString
        )

        guard let url = URL(
            string: urlString
        ) else {
            print(
                "❌ URL inválida:",
                urlString
            )

            throw AuthenticationServiceError.invalidURL
        }

        let requestData: Data

        do {
            requestData =
                try JSONEncoder().encode(
                    requestBody
                )
        } catch {
            print(
                "❌ Erro ao codificar login:",
                error
            )

            throw AuthenticationServiceError
                .unknownError
        }

        if let jsonString = String(
            data: requestData,
            encoding: .utf8
        ) {
            print(
                """
                📤 Corpo da requisição JSON (Login):
                \(jsonString)
                """
            )
        }

        var request = URLRequest(
            url: url
        )

        request.httpMethod = "POST"
        request.timeoutInterval = 30

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody =
            requestData

        print(
            "🚀 Iniciando request de login..."
        )

        let responseData: Data
        let response: URLResponse

        do {
            (
                responseData,
                response
            ) = try await URLSession.shared.data(
                for: request
            )

            print(
                "📡 URLSession retornou resposta."
            )

        } catch let error as URLError {
            print(
                """
                ❌ URLError no login
                Code: \(error.code.rawValue)
                Tipo: \(error.code)
                Descrição: \(error.localizedDescription)
                URL: \(url.absoluteString)
                """
            )

            throw error

        } catch {
            print(
                """
                ❌ Erro de rede no login:
                \(error)
                """
            )

            throw error
        }

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            print(
                "❌ Resposta não é HTTP."
            )

            throw AuthenticationServiceError
                .invalidResponse
        }

        print(
            """
            ✅ Código de resposta (Login):
            \(httpResponse.statusCode)
            """
        )

        if let rawResponse = String(
            data: responseData,
            encoding: .utf8
        ) {
            print(
                """
                📦 Resposta bruta:
                \(rawResponse)
                """
            )
        }

        guard
            200..<300 ~= httpResponse.statusCode
        else {
            throw makeStatusCodeError(
                statusCode:
                    httpResponse.statusCode,
                data:
                    responseData
            )
        }

        do {
            let decoder =
                JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            let loggedInUser =
                try decoder.decode(
                    AuthenticationLoginResponse.self,
                    from: responseData
                )

            print(
                """
                ✅ Login decodificado com sucesso:
                \(loggedInUser)
                """
            )

            return loggedInUser

        } catch {
            print(
                """
                ❌ Erro ao decodificar login:
                \(error)
                """
            )

            throw AuthenticationServiceError
                .decodingError(error)
        }
    }
}

// MARK: - Error handling

private extension AuthenticationService {
    func makeStatusCodeError(
        statusCode: Int,
        data: Data
    ) -> AuthenticationServiceError {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy =
            .convertFromSnakeCase

        if let response = try? decoder.decode(
            AuthenticationObjectErrorResponse.self,
            from: data
        ) {
            if response.detail.code
                == "email_not_verified",
               let email = response.detail.email {

                return .emailNotVerified(
                    email: email,
                    message:
                        response.detail.message
                )
            }

            return .badStatusCode(
                statusCode: statusCode,
                message:
                    response.detail.message
            )
        }

        if let response = try? decoder.decode(
            AuthenticationStringErrorResponse.self,
            from: data
        ) {
            return .badStatusCode(
                statusCode: statusCode,
                message: response.detail
            )
        }

        return .badStatusCode(
            statusCode: statusCode,
            message: String(
                data: data,
                encoding: .utf8
            )
        )
    }
}
struct ErrorResponse: Decodable {
    let detail: String
}
