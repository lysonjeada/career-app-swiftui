//
//  ProgressDashboardService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import Foundation

protocol ProgressDashboardServiceProtocol {
    func fetchProgressDashboard(
        months: Int
    ) async throws -> ProgressDashboard
}

final class ProgressDashboardService:
    ProgressDashboardServiceProtocol {

    func fetchProgressDashboard(
        months: Int
    ) async throws -> ProgressDashboard {
        guard var components = URLComponents(
            string: "\(APIConstants.pythonURL)/dashboard/progress"
        ) else {
            throw ProgressDashboardServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name: "months",
                value: String(months)
            )
        ]

        guard let url = components.url else {
            throw ProgressDashboardServiceError.invalidURL
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.timeoutInterval = 60

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw ProgressDashboardServiceError
                .invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(
                data: data,
                encoding: .utf8
            )

            throw ProgressDashboardServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message: message
                )
        }

        do {
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            decoder.dateDecodingStrategy =
                .iso8601

            return try decoder.decode(
                ProgressDashboard.self,
                from: data
            )

        } catch {
            print(
                "❌ Erro ao decodificar dashboard:",
                error
            )

            print(
                "📦 Resposta:",
                String(
                    data: data,
                    encoding: .utf8
                ) ?? "Sem conteúdo"
            )

            throw ProgressDashboardServiceError
                .decodingFailed(
                    error.localizedDescription
                )
        }
    }
}

private enum ProgressDashboardServiceError:
    LocalizedError {

    case invalidURL
    case invalidResponse
    case decodingFailed(String)

    case serverError(
        statusCode: Int,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL do dashboard é inválida."

        case .invalidResponse:
            return "O servidor retornou uma resposta inválida."

        case let .decodingFailed(message):
            return """
            Não foi possível interpretar os dados do dashboard: \(message)
            """

        case let .serverError(
            statusCode,
            message
        ):
            return """
            Erro \(statusCode): \(message ?? "Erro desconhecido.")
            """
        }
    }
}
