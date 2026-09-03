//
//  SavedQuestionsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 02/09/26.
//

import Foundation

@MainActor
final class SavedQuestionsViewModel:
    ObservableObject {

    enum State:
        Equatable {

        case loading
        case loaded
        case error
    }

    @Published private(set)
    var questionSets: [SavedQuestionSet] = []

    @Published private(set)
    var viewState: State =
        .loading

    private let service:
        InterviewSimulationServiceProtocol

    init(
        service:
            InterviewSimulationServiceProtocol =
            InterviewSimulationService()
    ) {
        self.service = service
    }

    func fetchSavedQuestions() {
        viewState =
            .loading

        Task {
            do {
                questionSets =
                    try await service
                        .fetchSavedQuestions()

                viewState =
                    .loaded

            } catch {
                print(
                    """
                    ❌ Perguntas salvas:
                    \(error)
                    """
                )

                viewState =
                    .error
            }
        }
    }
}
