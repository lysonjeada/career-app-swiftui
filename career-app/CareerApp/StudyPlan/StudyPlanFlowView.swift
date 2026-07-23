//
//  StudyPlanFlowView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI

struct StudyPlanFlowView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel:
        StudyPlanViewModel

    init(
        service: StudyPlanServiceProtocol =
            StudyPlanService()
    ) {
        _viewModel = StateObject(
            wrappedValue: StudyPlanViewModel(
                service: service
            )
        )
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                StudyPlanSetupView(
                    viewModel: viewModel
                )

            case .loading:
                StudyPlanLoadingView()

            case .loaded:
                StudyPlanResultView(
                    viewModel: viewModel,
                    closeAction: {
                        dismiss()
                    }
                )

            case let .error(message):
                StudyPlanErrorView(
                    message: message,
                    retryAction: {
                        Task {
                            await viewModel.retry()
                        }
                    },
                    restartAction: {
                        viewModel.restart()
                    }
                )
            }
        }
        .navigationTitle("Plano de estudos")
        .navigationBarTitleDisplayMode(.inline)
    }
}
