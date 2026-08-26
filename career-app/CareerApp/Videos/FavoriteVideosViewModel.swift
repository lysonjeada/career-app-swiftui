//
//  FavoriteVideosViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/08/26.
//

import Foundation

@MainActor
final class FavoriteVideosViewModel:
    ObservableObject {

    enum State:
        Equatable {

        case loading
        case loaded
        case error
    }

    @Published private(set)
    var videos: [TechVideo] = []

    @Published private(set)
    var viewState: State =
        .loading

    @Published private(set)
    var isLoadingMore =
        false

    @Published private(set)
    var removalErrorMessage:
        String?

    private var page = 1

    private let pageSize = 10

    private var hasNext =
        true

    private let service:
        VideoServiceProtocol

    init(
        service:
            VideoServiceProtocol =
            VideoService()
    ) {
        self.service = service
    }

    func fetchFavorites() {
        page = 1
        hasNext = true

        viewState =
            .loading

        Task {
            do {
                let response =
                    try await service
                        .fetchFavoriteVideos(
                            page: 1,
                            pageSize:
                                pageSize
                        )

                videos =
                    response.items

                hasNext =
                    response.hasNext

                viewState =
                    .loaded

            } catch {
                print(
                    """
                    ❌ Favoritos:
                    \(error)
                    """
                )

                viewState =
                    .error
            }
        }
    }

    func loadMoreIfNeeded(
        video: TechVideo
    ) {
        guard
            video.id
            == videos.last?.id,
            hasNext,
            !isLoadingMore
        else {
            return
        }

        loadMore()
    }

    private func loadMore() {
        isLoadingMore =
            true

        let nextPage =
            page + 1

        Task {
            defer {
                isLoadingMore =
                    false
            }

            do {
                let response =
                    try await service
                        .fetchFavoriteVideos(
                            page:
                                nextPage,
                            pageSize:
                                pageSize
                        )

                videos.append(
                    contentsOf:
                        response.items
                )

                page =
                    nextPage

                hasNext =
                    response.hasNext

            } catch {
                print(
                    """
                    ❌ Paginação de favoritos:
                    \(error)
                    """
                )
            }
        }
    }

    func removeFavorite(
        _ video: TechVideo
    ) {
        Task {
            do {
                _ = try await service
                    .removeFavorite(
                        videoId: video.id
                    )

                videos.removeAll {
                    $0.id == video.id
                }

            } catch {
                print(
                    """
                    ❌ Remover favorito:
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
