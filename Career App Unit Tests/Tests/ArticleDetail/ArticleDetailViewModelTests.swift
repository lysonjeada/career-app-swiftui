//
//  ArticleDetailViewModelTests.swift
//  career-app
//

import Foundation
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

    // Regressão: reabrir um artigo já favoritado (ex.: veio da tela de
    // Favoritos) precisa mostrar a estrela já selecionada. Uma NOVA
    // instância do ViewModel simula exatamente "sair da tela e entrar
    // de novo" — o fixture tem "is_favorited": true.
    @Test @MainActor
    func testFetchArticles_ReopeningFavoritedArticle_StartsWithIsFavoritedTrue() async throws {
        // Arrange
        let service = ArticleServiceMock(isSuccess: true)
        let viewModel = ArticleDetailViewModel(articleId: 2315711, service: service)

        // Act
        viewModel.fetchArticles()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.isFavorited == true)
    }
}

// Regressão do bug real: ArticleService.fetchArticle usava
// `decoder.keyDecodingStrategy = .convertFromSnakeCase` NUM TIPO que
// já declara `CodingKeys` explícitos em snake_case (ex.: `case
// isFavorited = "is_favorited"`). A estratégia convertia a chave do
// JSON pra "isFavorited" e o decoder tentava casar com o
// `stringValue` do CodingKey — que é literalmente "is_favorited", não
// "isFavorited". Toda propriedade Optional com CodingKey explícito
// virava nil em silêncio (era por isso que a estrela de favorito
// voltava desmarcada ao reabrir o artigo). Este teste garante que
// decodificar com um `JSONDecoder()` simples — a configuração correta
// hoje usada em ArticleService — preenche esses campos.
@Suite
struct ArticleDetailDecodingTests {
    @Test
    func testDecodingWithPlainDecoder_PopulatesSnakeCaseMappedFields() throws {
        let json = """
        {
            "id": 42,
            "title": "Artigo",
            "is_favorited": true,
            "comments_count": 7,
            "cover_image": "https://dev.to/cover.png"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(ArticleDetail.self, from: json)

        #expect(decoded.isFavorited == true)
        #expect(decoded.commentsCount == 7)
        #expect(decoded.coverImage == "https://dev.to/cover.png")
    }
}
