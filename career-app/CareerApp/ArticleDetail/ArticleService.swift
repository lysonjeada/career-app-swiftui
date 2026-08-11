//
//  ArticleService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import Foundation

protocol ArticleServiceProtocol {
    func fetchArticle(id: Int) async throws -> ArticleDetail
}

final class ArticleService: ArticleServiceProtocol {
    func fetchArticle(id: Int) async throws -> ArticleDetail {
        print("🟢 Iniciando fetchArticle para o ID: \(id)")
        
        // 1. Verificação da URL
        guard let url = URL(string: "https://dev.to/api/articles/\(id)") else {
            print("🔴 Erro: URL inválida para o ID \(id)")
            throw URLError(.badURL)
        }
        print("🟡 URL construída: \(url.absoluteString)")
        
        // 2. Chamada à API
        do {
            print("🟡 Fazendo requisição...")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // 3. Verificação do status HTTP (opcional)
            if let httpResponse = response as? HTTPURLResponse {
                print("🟡 Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("🔴 Erro: Status HTTP inesperado (\(httpResponse.statusCode))")
                }
            }
            
            // 4. Log dos dados brutos (útil para debug)
            let rawDataString = String(data: data, encoding: .utf8)
            print("🟡 Dados brutos recebidos: \(rawDataString ?? "vazio/não decodificável")")
            
            // 5. Decodificação
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Caso a API use snake_case
            let fetchedArticle = try decoder.decode(ArticleDetail.self, from: data)
            print("🟢 Artigo decodificado com sucesso: \(fetchedArticle)")
            return fetchedArticle
            
        } catch {
            print("🔴 Erro durante a requisição ou decodificação: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("Detalhes do erro:", decodingError.localizedDescription)
            }
            throw error // Re-lança o erro para o caller
        }
    }
}
