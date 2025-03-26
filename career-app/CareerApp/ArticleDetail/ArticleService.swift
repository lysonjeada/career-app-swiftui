//
//  ArticleService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import Foundation

final class ArticleService {
    func fetchArticle(id: Int) async throws(Error) -> ArticleDetail {
        guard let url = URL(string: "https://dev.to/api/articles/\(String(id))") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let fetchedArticles = try decoder.decode(ArticleDetail.self, from: data)
        return fetchedArticles
    }
}
