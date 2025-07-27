//
//  APIError.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/07/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    case clientError(statusCode: Int, message: String?)
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .serverError(let statusCode, let message):
            return "Erro do servidor (\(statusCode)): \(message ?? "Ocorreu um erro no servidor.")"
        case .clientError(let statusCode, let message):
            return "Erro na requisição (\(statusCode)): \(message ?? "Dados inválidos enviados.")"
        case .unknownError(let error):
            return "Ocorreu um erro desconhecido: \(error.localizedDescription)"
        }
    }
}
