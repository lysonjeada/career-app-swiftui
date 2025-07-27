//
//  ProfileService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(userId: String) async throws -> AuthenticationLoginResponse
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
