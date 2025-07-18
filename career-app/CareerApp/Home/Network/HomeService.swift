//
//  HomeService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation

protocol HomeServiceProtocol {
    func fetchArticles(tag: String?) async throws -> [Article]
}

final class HomeService: HomeServiceProtocol {
    func fetchArticles(tag: String? = nil) async throws -> [Article] {
        var urlString = "https://dev.to/api/articles"
        if let tag = tag, !tag.isEmpty {
            urlString += "?tag=\(tag)"
        }
        
        guard let url = URL(string: urlString) else {
            print("[HomeService] ❌ URL inválida: \(urlString)")
            throw URLError(.badURL)
        }
        
        do {
            print("[HomeService] 🔄 Iniciando requisição para: \(url)")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("[HomeService] ✅ Código de resposta: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            let fetchedArticles = try decoder.decode([Article].self, from: data)
            print("[HomeService] ✅ Artigos decodificados com sucesso. Total: \(fetchedArticles.count)")
            return fetchedArticles
        } catch {
            print("[HomeService] ❌ Erro ao buscar ou decodificar artigos: \(error.localizedDescription)")
            throw error
        }
    }
}

