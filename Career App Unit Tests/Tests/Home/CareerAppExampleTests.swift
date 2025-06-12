//
//  CareerAppExampleTests.swift
//  CareerAppExampleTests
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import XCTest
@testable import career_app

class MockHomeCoordinatorDelegate: HomeViewModelCoordinatorDelegate {
    var didCallGoToArticleDetail = false
    var receivedArticleId: Int?
    
    func goToArticleDetail(articleId: Int) {
        didCallGoToArticleDetail = true
        receivedArticleId = articleId
    }
}

// Mock do HomeService para simular respostas
class MockHomeService: HomeService {
    var shouldSucceed = true
    var mockArticles: [Article] = [
        Article(id: 1, title: "Test Article 1", content: "Content 1"),
        Article(id: 2, title: "Test Article 2", content: "Content 2")
    ]
    var mockError: Error = NSError(domain: "TestError", code: 1, userInfo: nil)
    
    override func fetchArticles() async throws -> [Article] {
        if shouldSucceed {
            return mockArticles
        } else {
            throw mockError
        }
    }
}

struct CareerAppExampleTests: XCTestCase {

    func testExample() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}
