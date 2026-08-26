//
//  FavoriteArticlesViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/08/26.
//

import Foundation

@MainActor
final class FavoriteArticlesViewModel:
    ObservableObject {

    enum State:
        Equatable {

        case loading
        case loaded
        case error
    }

    @Published private(set)
    var articles: [ArticleDetail] = []

    @Published private(set)
    var viewState: State =
        .loading

    @Published private(set)
    var removalErrorMessage:
        String?

    private let service:
        ArticleServiceProtocol

    init(
        service:
            ArticleServiceProtocol =
            ArticleService()
    ) {
        self.service = service
    }

    func fetchFavorites() {
        viewState =
            .loading

        Task {
            do {
                articles =
                    try await service
                        .fetchFavoriteArticles()

                viewState =
                    .loaded

            } catch {
                print(
                    """
                    ❌ Favoritos de artigos:
                    \(error)
                    """
                )

                viewState =
                    .error
            }
        }
    }

    func removeFavorite(
        _ article: ArticleDetail
    ) {
        guard let id = article.id else {
            return
        }

        Task {
            do {
                _ = try await service
                    .removeFavorite(
                        articleId: id
                    )

                articles.removeAll {
                    $0.id == id
                }

            } catch {
                print(
                    """
                    ❌ Remover artigo dos favoritos:
                    \(error)
                    """
                )

                removalErrorMessage =
                    "Não foi possível remover dos favoritos."
            }
        }
    }

    func clearRemovalError() {
        removalErrorMessage = nil
    }
}
