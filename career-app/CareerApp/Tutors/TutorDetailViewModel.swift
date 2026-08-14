//
//  TutorDetailViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation

@MainActor
final class TutorDetailViewModel:
    ObservableObject {

    enum State: Equatable {
        case loading
        case loaded
        case error
    }

    @Published private(set)
    var tutor: Tutor?

    @Published private(set)
    var viewState: State =
        .loading

    private let service:
        TutorServiceProtocol

    init(
        service:
            TutorServiceProtocol =
            TutorService()
    ) {
        self.service = service
    }

    func fetchTutor(
        id: String
    ) {
        viewState = .loading

        Task {
            do {
                tutor =
                    try await service
                        .fetchTutor(
                            id: id
                        )

                viewState =
                    .loaded

            } catch {
                print(
                    """
                    ❌ Erro ao carregar tutor:
                    \(error)
                    """
                )

                viewState =
                    .error
            }
        }
    }
}
