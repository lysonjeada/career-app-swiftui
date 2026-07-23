//
//  StudyPlanResultView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI

struct StudyPlanResultView: View {

    @ObservedObject var viewModel:
        StudyPlanViewModel

    let closeAction: () -> Void

    var body: some View {
        ScrollView {
            if let plan = viewModel.studyPlan {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    StudyPlanProgressCard(
                        plan: plan,
                        completedTopics:
                            viewModel.completedTopicsCount,
                        totalTopics:
                            viewModel.totalTopicsCount,
                        progress: viewModel.progress
                    )

                    ForEach(plan.topics) { topic in
                        StudyPlanTopicCard(
                            topic: topic,
                            toggleAction: {
                                withAnimation {
                                    viewModel.toggleTopic(
                                        id: topic.id
                                    )
                                }
                            }
                        )
                    }

                    Button {
                        viewModel.restart()
                    } label: {
                        Label(
                            "Gerar outro plano",
                            systemImage: "arrow.clockwise"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(
                        "Finalizar",
                        action: closeAction
                    )
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
    }
}

private struct StudyPlanProgressCard: View {
    let plan: StudyPlan
    let completedTopics: Int
    let totalTopics: Int
    let progress: Double

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            Text(plan.title)
                .font(.title2)
                .bold()
                .foregroundColor(.persianBlue)

            Text(plan.summary)
                .foregroundStyle(.secondary)

            Label(
                "\(plan.estimatedTotalHours) horas estimadas",
                systemImage: "clock"
            )
            .font(.subheadline)
            .foregroundColor(.persianBlue)

            HStack {
                Text("Progresso")
                    .font(.headline)

                Spacer()

                Text(
                    "\(completedTopics)/\(totalTopics)"
                )
                .font(.subheadline)
                .bold()
            }

            ProgressView(value: progress)
                .tint(.persianBlue)

            Text(
                "\(Int(progress * 100))% concluído"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Color.persianBlue.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

#Preview("Plano de estudos — Resultado") {
    StudyPlanResultPreviewContainer()
}
