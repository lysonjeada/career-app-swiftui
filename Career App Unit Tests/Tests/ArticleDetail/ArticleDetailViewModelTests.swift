//
//  ArticleDetailViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct ArticleDetailViewModelTests {
    @Test @MainActor
    func testFetchArticles_Success_SetsLoadedStateAndPopulatesArticle() async throws {
        // Arrange
        let service = ArticleServiceMock(isSuccess: true)
        let viewModel = ArticleDetailViewModel(articleId: 2315711, service: service)

        // Act
        viewModel.fetchArticles()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.article?.id == 2315711)
        #expect(viewModel.article?.title == "Testando o ArticleDetailViewModel")
        #expect(service.receivedArticleId == 2315711)
    }

    @Test @MainActor
    func testFetchArticles_WhenServiceFails_KeepsLoadingStateWithoutArticle() async throws {
        // Arrange — o ViewModel hoje não possui estado de erro: em caso de falha,
        // apenas registra o erro no console e mantém o estado .loading.
        let service = ArticleServiceMock(isSuccess: false)
        let viewModel = ArticleDetailViewModel(articleId: 2315711, service: service)

        // Act
        viewModel.fetchArticles()
        try await Task.sleep(nanoseconds: 3_000_000_000)

        // Assert
        #expect(viewModel.viewState == .loading)
        #expect(viewModel.article == nil)
        #expect(service.receivedArticleId == 2315711)
    }
}
