//
//  HomeService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation

final class HomeService {
    func fetchArticles() async throws(Error) -> [Article] {
        guard let url = URL(string: "https://dev.to/api/articles") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let fetchedArticles = try decoder.decode([Article].self, from: data)
        return fetchedArticles
    }
}
