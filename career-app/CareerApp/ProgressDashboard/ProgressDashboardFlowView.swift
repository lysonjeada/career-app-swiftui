//
//  ProgressDashboardFlowView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI

struct ProgressDashboardFlowView: View {

    @StateObject private var viewModel:
        ProgressDashboardViewModel

    init(
        service:
            ProgressDashboardServiceProtocol =
            ProgressDashboardService()
    ) {
        _viewModel = StateObject(
            wrappedValue:
                ProgressDashboardViewModel(
                    service: service
                )
        )
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressDashboardLoadingView()

            case let .loaded(dashboard):
                ProgressDashboardView(
                    dashboard: dashboard,
                    selectedMonths:
                        viewModel.selectedMonths,
                    changePeriodAction: { months in
                        Task {
                            await viewModel.changePeriod(
                                to: months
                            )
                        }
                    },
                    refreshAction: {
                        await viewModel.load(
                            forceReload: true
                        )
                    }
                )

            case let .error(message):
                ProgressDashboardErrorView(
                    message: message,
                    retryAction: {
                        Task {
                            await viewModel.retry()
                        }
                    }
                )
            }
        }
        .navigationTitle("Seu progresso")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}
