//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct InterviewSimulationResultView: View {
    let evaluation: InterviewSimulationEvaluation
    let onRestart: () -> Void
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                resultHeader

                VStack(spacing: 14) {
                    EvaluationScoreRow(
                        title: "Clareza",
                        icon: "text.alignleft",
                        score: evaluation.clarity
                    )

                    EvaluationScoreRow(
                        title: "Objetividade",
                        icon: "scope",
                        score: evaluation.objectivity
                    )

                    EvaluationScoreRow(
                        title: "Uso de exemplos",
                        icon: "quote.bubble",
                        score: evaluation.examples
                    )

                    EvaluationScoreRow(
                        title: "Conhecimento técnico",
                        icon: "chevron.left.forwardslash.chevron.right",
                        score: evaluation.technicalKnowledge
                    )

                    EvaluationScoreRow(
                        title: "Tempo de resposta",
                        icon: "timer",
                        score: evaluation.responseTime
                    )
                }

                EvaluationTextSection(
                    title: "Resumo",
                    icon: "text.document",
                    values: [evaluation.summary]
                )

                EvaluationTextSection(
                    title: "Pontos fortes",
                    icon: "star.fill",
                    values: evaluation.strengths
                )

                EvaluationTextSection(
                    title: "O que melhorar",
                    icon: "arrow.up.circle.fill",
                    values: evaluation.improvements
                )

                Button(
                    "Refazer entrevista",
                    action: onRestart
                )
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button(
                    "Finalizar",
                    action: onClose
                )
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }

    private var resultHeader: some View {
        VStack(spacing: 12) {
            Text("Resultado")
                .font(.title2)
                .bold()
                .foregroundColor(.persianBlue)

            ZStack {
                Circle()
                    .stroke(
                        Color.persianBlue.opacity(0.15),
                        lineWidth: 12
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: Double(evaluation.overall) / 100
                    )
                    .stroke(
                        Color.persianBlue,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(evaluation.overall)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.persianBlue)
            }
            .frame(width: 130, height: 130)

            Text("Pontuação geral")
                .font(.headline)
        }
    }
}

private struct EvaluationScoreRow: View {
    let title: String
    let icon: String
    let score: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(
                    title,
                    systemImage: icon
                )
                .font(.headline)

                Spacer()

                Text("\(score)/100")
                    .bold()
                    .foregroundColor(.persianBlue)
            }

            ProgressView(
                value: Double(score),
                total: 100
            )
            .tint(.persianBlue)
        }
        .padding()
        .background(Color.gray.opacity(0.07))
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}

private struct EvaluationTextSection: View {
    let title: String
    let icon: String
    let values: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                title,
                systemImage: icon
            )
            .font(.headline)
            .foregroundColor(.persianBlue)

            ForEach(values, id: \.self) { value in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 7)

                    Text(value)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.07))
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}
