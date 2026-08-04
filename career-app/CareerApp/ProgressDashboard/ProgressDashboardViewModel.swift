//
//  ProgressDashboardViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import Foundation

@MainActor
final class ProgressDashboardViewModel:
    ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded(ProgressDashboard)
        case error(String)
    }

    @Published private(set) var state:
        State = .idle

    @Published var selectedMonths = 6

    private let service:
        ProgressDashboardServiceProtocol

    init(
        service: ProgressDashboardServiceProtocol =
            ProgressDashboardService()
    ) {
        self.service = service
    }

    func load(
        forceReload: Bool = false
    ) async {
        if !forceReload,
           case .loaded = state {
            return
        }

        state = .loading

        do {
            let dashboard =
                try await service
                    .fetchProgressDashboard(
                        months: selectedMonths
                    )

            state = .loaded(dashboard)

        } catch {
            state = .error(
                error.localizedDescription
            )
        }
    }

    func changePeriod(
        to months: Int
    ) async {
        guard months != selectedMonths else {
            return
        }

        selectedMonths = months

        await load(
            forceReload: true
        )
    }

    func retry() async {
        await load(
            forceReload: true
        )
    }
}
