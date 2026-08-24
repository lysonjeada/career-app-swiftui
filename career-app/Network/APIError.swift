//
//  APIError.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/07/25.
//

import Foundation

// MARK: - Custom Error Types
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    case clientError(statusCode: Int, message: String?)
    case decodingError(Error) // Para erros de JSON decoding
    case encodingError(Error) // Para erros de JSON encoding
    case unknownError(Error)
    case insufficientCredits
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida. Verifique o endereço do servidor."
        case .invalidResponse:
            return "Resposta inválida do servidor. Formato inesperado."
        case .serverError(let statusCode, let message):
            return "Erro do servidor (\(statusCode)): \(message ?? "Ocorreu um erro interno no servidor.")"
        case .clientError(let statusCode, let message):
            return "Erro na requisição (\(statusCode)): \(message ?? "Verifique os dados enviados e tente novamente.")"
        case .decodingError(let error):
            return "Erro ao processar a resposta do servidor: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Erro ao preparar os dados para enviar: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Ocorreu um erro desconhecido: \(error.localizedDescription)"
        case .insufficientCredits:
            return "Você não possui créditos de IA suficientes."
        case .unauthorized:
            return "Sua sessão expirou. Faça login novamente."
        }
    }

    /// Mapeia um status HTTP + corpo de resposta para o erro
    /// apropriado. O backend responde erros como
    /// `{"detail": {"code": "...", "message": "..."}}` (créditos
    /// insuficientes, produto desconhecido etc) ou
    /// `{"detail": "mensagem simples"}` (validação genérica) — os
    /// dois formatos são tratados aqui. Usado pelos services de IA
    /// (GenerateQuestionsService, StudyPlanService,
    /// InterviewSimulationService, InterviewService, AICreditsService)
    /// para não duplicar essa detecção em cada um.
    static func from(statusCode: Int, data: Data) -> APIError {
        if statusCode == 402,
           let envelope = try? JSONDecoder().decode(
                APIErrorDetailEnvelope.self,
                from: data
           ),
           envelope.detail.code == "INSUFFICIENT_AI_CREDITS" {
            return .insufficientCredits
        }

        if statusCode == 401 {
            return .unauthorized
        }

        let message = Self.message(from: data)

        if 400..<500 ~= statusCode {
            return .clientError(statusCode: statusCode, message: message)
        }

        return .serverError(statusCode: statusCode, message: message)
    }

    private static func message(from data: Data) -> String? {
        if let envelope = try? JSONDecoder().decode(
            APIErrorDetailEnvelope.self,
            from: data
        ) {
            return envelope.detail.message
        }

        if let envelope = try? JSONDecoder().decode(
            APISimpleErrorDetailEnvelope.self,
            from: data
        ) {
            return envelope.detail
        }

        return String(data: data, encoding: .utf8)
    }
}

private struct APIErrorDetailEnvelope: Decodable {
    struct Detail: Decodable {
        let code: String?
        let message: String?
    }

    let detail: Detail
}

private struct APISimpleErrorDetailEnvelope: Decodable {
    let detail: String
}
