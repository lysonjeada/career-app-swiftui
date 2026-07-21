//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct InterviewSimulationFlowView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel:
        InterviewSimulationViewModel

    init(
        service: InterviewSimulationServiceProtocol =
            InterviewSimulationService()
    ) {
        _viewModel = StateObject(
            wrappedValue: InterviewSimulationViewModel(
                service: service
            )
        )
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                InterviewSimulationSetupView(
                    viewModel: viewModel
                )

            case .loadingQuestions:
                SimulationLoadingView(
                    title: "Preparando entrevista",
                    message: "Gerando perguntas para a vaga..."
                )

            case .answering, .transcribing:
                InterviewSimulationSessionView(
                    viewModel: viewModel
                )

            case .evaluating:
                SimulationLoadingView(
                    title: "Avaliando respostas",
                    message: "Analisando seu desempenho..."
                )

            case .completed:
                if let evaluation = viewModel.evaluation {
                    InterviewSimulationResultView(
                        evaluation: evaluation,
                        onRestart: {
                            viewModel.restart()
                        },
                        onClose: {
                            dismiss()
                        }
                    )
                }

            case .evaluationFailed:
                SimulationEvaluationErrorView(
                    message: viewModel.errorMessage ??
                        "Não foi possível avaliar a entrevista.",
                    retryAction: {
                        Task {
                            await viewModel.retryEvaluation()
                        }
                    },
                    restartAction: {
                        viewModel.restart()
                    }
                )
            }
        }
        .navigationTitle("Entrevista simulada")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Atenção",
            isPresented: Binding(
                get: {
                    viewModel.errorMessage != nil &&
                    viewModel.state != .evaluationFailed
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearError()
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
