//
//  SavedQuestionsView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 02/09/26.
//

import SwiftUI

struct SavedQuestionsView: View {
    @StateObject
    private var viewModel =
        SavedQuestionsViewModel()

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()

            case .loaded:
                if viewModel.questionSets.isEmpty {
                    emptyState
                } else {
                    questionSetList
                }

            case .error:
                ContentUnavailableView {
                    Label(
                        "Não foi possível carregar as perguntas salvas",
                        systemImage:
                            "star.slash"
                    )
                } actions: {
                    Button(
                        "Tentar novamente"
                    ) {
                        viewModel.fetchSavedQuestions()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchSavedQuestions()
        }
    }

    private var emptyState:
        some View {

        ContentUnavailableView {
            Label(
                "Nenhuma pergunta salva",
                systemImage:
                    "star.slash"
            )
        } description: {
            Text(
                "Ao gerar perguntas para uma entrevista, toque em \"Salvar perguntas\" para encontrá-las aqui depois."
            )
        }
    }

    private var questionSetList:
        some View {

        List {
            ForEach(
                viewModel.questionSets
            ) { questionSet in

                SavedQuestionSetRow(
                    questionSet: questionSet
                )
                .listRowSeparator(
                    .hidden
                )
                .listRowBackground(
                    Color.clear
                )
                .listRowInsets(
                    EdgeInsets(
                        top: 7,
                        leading: 16,
                        bottom: 7,
                        trailing: 16
                    )
                )
            }
        }
        .listStyle(.plain)
    }
}

private struct SavedQuestionSetRow: View {
    let questionSet: SavedQuestionSet

    @State
    private var isExpanded = false

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded
        ) {
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(
                    questionSet.questions,
                    id: \.self
                ) { question in

                    Text(
                        "•  \(question)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .primary
                    )
                }
            }
            .padding(.top, 10)
        } label: {
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(
                    questionSet.jobTitle
                )
                .font(.headline)
                .foregroundStyle(
                    .primary
                )

                Text(
                    "\(questionSet.seniority) · \(questionSet.questions.count) perguntas"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }
        }
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}
