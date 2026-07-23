//
//  StudyPlanTopicCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI

struct StudyPlanTopicCard: View {
    let topic: StudyPlanTopic
    let toggleAction: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(alignment: .top) {
                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Text(topic.title)
                        .font(.headline)
                        .strikethrough(
                            topic.isCompleted
                        )

                    Label(
                        topic.priority.title,
                        systemImage: topic.priority.icon
                    )
                    .font(.caption)
                    .foregroundColor(.cardBackground)
                }

                Spacer()

                Button(action: toggleAction) {
                    Image(
                        systemName: topic.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.title2)
                    .foregroundColor(.persianBlue)
                }
                .buttonStyle(.plain)
            }

            Text(topic.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(
                "\(topic.estimatedHours) horas",
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundColor(.persianBlue)

            if !topic.subtopics.isEmpty {
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("O que estudar")
                        .font(.subheadline)
                        .bold()

                    ForEach(
                        topic.subtopics,
                        id: \.self
                    ) { subtopic in
                        HStack(
                            alignment: .top,
                            spacing: 8
                        ) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 5))
                                .padding(.top, 6)

                            Text(subtopic)
                                .font(.subheadline)
                        }
                    }
                }
            }

            if !topic.practice.isEmpty {
                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    Label(
                        "Prática sugerida",
                        systemImage: "hammer.fill"
                    )
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.persianBlue)

                    Text(topic.practice)
                        .font(.subheadline)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color.gray.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    topic.isCompleted
                        ? Color.persianBlue
                        : Color.gray.opacity(0.25),
                    lineWidth: topic.isCompleted ? 2 : 1
                )
        }
        .opacity(
            topic.isCompleted ? 0.7 : 1
        )
    }
}

struct StudyPlanLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text("Criando seu plano")
                .font(.title3)
                .bold()
                .foregroundColor(.persianBlue)

            Text(
                "Analisando a vaga e preparando sua trilha..."
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
    }
}

struct StudyPlanErrorView: View {
    let message: String
    let retryAction: () -> Void
    let restartAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(
                systemName: "exclamationmark.triangle"
            )
            .font(.system(size: 50))
            .foregroundStyle(.secondary)

            Text("Não foi possível gerar o plano")
                .font(.title2)
                .bold()

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(
                "Tentar novamente",
                action: retryAction
            )
            .buttonStyle(.borderedProminent)

            Button(
                "Alterar informações",
                action: restartAction
            )
            .buttonStyle(.bordered)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
    }
}
