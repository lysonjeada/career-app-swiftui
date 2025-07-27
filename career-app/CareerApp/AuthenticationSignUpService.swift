//
//  AuthenticationSignUpService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

protocol AuthenticationServiceProtocol {
    func createRegister(requestBody: AuthenticationRegisterRequest) async throws
    func fetchLogin(requestBody: AuthenticationLoginRequest) async throws -> AuthenticationLoginResponse
}

enum AuthenticationServiceError: LocalizedError {
    case invalidResponse
    case badStatusCode(statusCode: Int, message: String?)
    case decodingError(Error)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Resposta inválida do servidor."
        case .badStatusCode(let statusCode, let message):
            if let msg = message, !msg.isEmpty {
                return "Erro do servidor (\(statusCode)): \(msg)"
            }
            return "O servidor retornou um erro inesperado: Código \(statusCode)."
        case .decodingError(let error):
            return "Erro ao decodificar a resposta do servidor: \(error.localizedDescription)"
        case .unknownError:
            return "Ocorreu um erro desconhecido."
        }
    }
}

// MARK: - Serviço de Autenticação (AuthenticationSignUpService)
class AuthenticationService: AuthenticationServiceProtocol {
    func createRegister(requestBody: AuthenticationRegisterRequest) async throws {
        guard let url = URL(string: "\(APIConstants.pythonURL)/users/register/") else {
            throw URLError(.badURL)
        }
        
        let data = try JSONEncoder().encode(requestBody)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Corpo da requisição JSON:")
            print(jsonString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationServiceError.invalidResponse // Se a resposta não for HTTP
        }
        
        print("✅ Código de resposta (POST): \(httpResponse.statusCode)")
        
        // --- ADIÇÃO DA VERIFICAÇÃO DO CÓDIGO DE STATUS ---
        // O status esperado para um novo recurso criado é 201 Created.
        guard httpResponse.statusCode == 201 else {
            // Tenta decodificar uma mensagem de erro do corpo da resposta, se houver
            var errorMessage: String? = nil
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: responseData) {
                errorMessage = errorResponse.detail
            } else if let rawString = String(data: responseData, encoding: .utf8), !rawString.isEmpty {
                errorMessage = rawString // Fallback para string pura se não for JSON
            }
            
            throw AuthenticationServiceError.badStatusCode(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Se a resposta for 201, você pode, opcionalmente, decodificar a resposta
        // se o backend retornar os dados do usuário registrado, por exemplo.
        // if let registeredUser = try? JSONDecoder().decode(AuthenticationRegisterResponse.self, from: responseData) {
        //     print("Usuário registrado: \(registeredUser)")
        // }
        
        if let responseBody = String(data: responseData, encoding: .utf8) {
            print("📥 Resposta do servidor:")
            print(responseBody)
        }
        // Se chegou aqui, a requisição foi bem-sucedida com o status esperado.
    }
}

extension AuthenticationService {
    func fetchLogin(requestBody: AuthenticationLoginRequest) async throws -> AuthenticationLoginResponse {
        guard let url = URL(string: "\(APIConstants.pythonURL)/users/login/") else {
            throw URLError(.badURL)
        }
        
        let data = try JSONEncoder().encode(requestBody)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Corpo da requisição JSON (Login):")
            print(jsonString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationServiceError.invalidResponse
        }
        
        print("✅ Código de resposta (POST Login): \(httpResponse.statusCode)")
        
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
            print("📥 Resposta do servidor (Login Sucesso):")
            print(loggedInUser)
            return loggedInUser
        } catch {
            print("❌ Erro ao decodificar resposta de sucesso do login: \(error.localizedDescription)")
            // Tenta logar o corpo da resposta bruta para depuração
            if let responseBody = String(data: responseData, encoding: .utf8) {
                print("Raw Response Body: \(responseBody)")
            }
            throw AuthenticationServiceError.decodingError(error)
        }
    }
}

struct ErrorResponse: Decodable {
    let detail: String
}
