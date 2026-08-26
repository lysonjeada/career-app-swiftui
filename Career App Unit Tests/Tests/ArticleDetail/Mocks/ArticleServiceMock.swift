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

    var favoriteResult = true
    private(set) var receivedFavoriteArticleId: Int?

    func addFavorite(articleId: Int) async throws -> Bool {
        receivedFavoriteArticleId = articleId

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return favoriteResult
    }

    func removeFavorite(articleId: Int) async throws -> Bool {
        receivedFavoriteArticleId = articleId

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return favoriteResult
    }

    var favoriteArticlesToReturn: [ArticleDetail] = []

    func fetchFavoriteArticles() async throws -> [ArticleDetail] {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return favoriteArticlesToReturn
    }
}
