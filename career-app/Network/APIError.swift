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
        }
    }
}
