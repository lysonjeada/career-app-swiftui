//
//  EmailVerificationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

import Foundation

protocol EmailVerificationServiceProtocol {
    func verifyEmail(
        email: String,
        code: String
    ) async throws
        -> EmailVerificationResponse

    func resendCode(
        email: String
    ) async throws
        -> ResendEmailVerificationResponse
}

final class EmailVerificationService:
    EmailVerificationServiceProtocol {

    func verifyEmail(
        email: String,
        code: String
    ) async throws
        -> EmailVerificationResponse {

        let requestBody =
            EmailVerificationRequest(
                email: email,
                code: code
            )

        return try await performRequest(
            path: "/users/verify-email",
            body: requestBody,
            responseType:
                EmailVerificationResponse.self
        )
    }

    func resendCode(
        email: String
    ) async throws
        -> ResendEmailVerificationResponse {

        let requestBody =
            ResendEmailVerificationRequest(
                email: email
            )

        return try await performRequest(
            path: "/users/resend-verification",
            body: requestBody,
            responseType:
                ResendEmailVerificationResponse.self
        )
    }

    private func performRequest<
        Body: Encodable,
        Response: Decodable
    >(
        path: String,
        body: Body,
        responseType: Response.Type
    ) async throws -> Response {
        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)\(path)"
        ) else {
            throw EmailVerificationServiceError
                .invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.timeoutInterval = 60

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody =
            try JSONEncoder().encode(body)

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw EmailVerificationServiceError
                .invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode
        else {
            let detail =
                Self.extractErrorMessage(
                    from: data
                )

            throw EmailVerificationServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message: detail
                )
        }

        do {
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            return try decoder.decode(
                Response.self,
                from: data
            )
        } catch {
            throw EmailVerificationServiceError
                .decodingFailed(
                    error.localizedDescription
                )
        }
    }

    private static func extractErrorMessage(
        from data: Data
    ) -> String {
        if let response =
            try? JSONDecoder().decode(
                APIErrorResponse.self,
                from: data
            ) {
            return response.detail
        }

        return String(
            data: data,
            encoding: .utf8
        ) ?? "Erro desconhecido."
    }
}

private struct APIErrorResponse:
    Decodable {

    let detail: String
}

enum EmailVerificationServiceError:
    LocalizedError {

    case invalidURL
    case invalidResponse
    case decodingFailed(String)

    case serverError(
        statusCode: Int,
        message: String
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return (
                """
                A URL de verificação
                é inválida.
                """
            )

        case .invalidResponse:
            return (
                """
                O servidor retornou 
                uma resposta inválida.
                """
            )

        case let .decodingFailed(message):
            return (
                """
                Não foi possível interpretar 
                a resposta: \(message)"
                """
            )

        case let .serverError(
            _,
            message
        ):
            return message
        }
    }
}
