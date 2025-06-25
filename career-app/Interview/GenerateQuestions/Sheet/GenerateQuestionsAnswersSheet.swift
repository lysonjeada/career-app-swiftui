//
//  GenerateQuestionsAnswersSheet.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import SwiftUI

struct GenerateQuestionsAnswersSheet: View {
    var generatedQuestions: [String] = []
    @Binding var showQuestionsView: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar com botão X
            HStack {
                Spacer()
                Button(action: {
                    showQuestionsView = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding()
                }
            }

            Text("Perguntas Geradas")
                .font(.title2)
                .bold()
                .padding(.horizontal)
                .padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(generatedQuestions.indices, id: \.self) { index in
                        let question = generatedQuestions[index]
                        HStack(alignment: .top, spacing: 8) {
                            Text(question)
                                .font(.body)
                                .padding(.vertical, 4)

                            Spacer()

                            Button(action: {
                                // Ex: viewModel.toggleFavorite(for: index)
                            }) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
            }

            Divider()

            HStack(spacing: 16) {
                Button("Gerar Mais") {
                    
                }
                .buttonStyle(.borderedProminent)

                Button("Salvar Todas") {
                    
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
