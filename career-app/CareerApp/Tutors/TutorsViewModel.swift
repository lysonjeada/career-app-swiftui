//
//  TutorsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation

@MainActor
final class TutorsViewModel:
    ObservableObject {

    enum State: Equatable {
        case loading
        case loaded
        case error
    }

    @Published private(set)
    var tutors: [Tutor] = []

    @Published private(set)
    var viewState: State = .loading

    @Published private(set)
    var isLoadingMore = false

    private var currentPage = 1

    private let pageSize = 10

    private var hasNextPage = true

    private let service:
        TutorServiceProtocol

    init(
        service: TutorServiceProtocol =
            TutorService()
    ) {
        self.service = service
    }

    func fetchTutors() {
        currentPage = 1
        hasNextPage = true
        tutors = []

        viewState = .loading

        Task {
            do {
                let response =
                    try await service.fetchTutors(
                        page: currentPage,
                        pageSize: pageSize
                    )

                tutors =
                    response.items

                hasNextPage =
                    response.hasNext

                viewState =
                    .loaded

            } catch {
                print(
                    """
                    ❌ Erro ao buscar tutores:
                    \(error)
                    """
                )

                viewState =
                    .error
            }
        }
    }

    func loadMoreIfNeeded(
        currentTutor: Tutor
    ) {
        guard let lastTutor =
                tutors.last,
              lastTutor.id
                == currentTutor.id
        else {
            return
        }

        loadMore()
    }

    private func loadMore() {
        guard hasNextPage,
              !isLoadingMore
        else {
            return
        }

        isLoadingMore = true

        let nextPage =
            currentPage + 1

        Task {
            defer {
                isLoadingMore =
                    false
            }

            do {
                let response =
                    try await service.fetchTutors(
                        page: nextPage,
                        pageSize: pageSize
                    )

                tutors.append(
                    contentsOf:
                        response.items
                )

                currentPage =
                    nextPage

                hasNextPage =
                    response.hasNext

            } catch {
                print(
                    """
                    ❌ Erro ao carregar
                    mais tutores:
                    \(error)
                    """
                )
            }
        }
    }
}
