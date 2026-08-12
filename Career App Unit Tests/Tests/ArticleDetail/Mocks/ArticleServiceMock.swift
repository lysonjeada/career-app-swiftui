//
//  ArticleServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class ArticleServiceMock: ArticleServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedArticleId: Int?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func fetchArticle(id: Int) async throws -> ArticleDetail {
        receivedArticleId = id

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("article-detail-response")
    }
}
