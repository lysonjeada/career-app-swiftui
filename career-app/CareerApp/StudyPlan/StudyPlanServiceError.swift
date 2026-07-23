//
//  StudyPlanServiceError.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import Foundation

enum StudyPlanServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case resumeReadFailed(String)
    case decodingFailed(String)
    case serverError(
        statusCode: Int,
        message: String?
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL do servidor é inválida."

        case .invalidResponse:
            return "O servidor retornou uma resposta inválida."

        case let .resumeReadFailed(message):
            return """
            Não foi possível ler o currículo: \(message)
            """

        case let .decodingFailed(message):
            return """
            Não foi possível interpretar o plano de estudos: \(message)
            """

        case let .serverError(statusCode, message):
            return """
            Erro \(statusCode): \(message ?? "Erro desconhecido.")
            """
        }
    }
}
