//
//  GenerateQuestionsAnswersSheet.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import SwiftUI

struct GenerateQuestionsAnswersSheet: View {
    @Binding var showQuestionsView: Bool
    @StateObject var viewModel: GenerateQuestionsViewModel
    @Binding var selectedJobTitle: String
    @Binding var selectedSeniority: String
    @Binding var jobDescription: String
    @Binding var resumeFileURL: URL?
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.viewState {
            case .loading:
                ZStack {
                    // Container centralizado
                    VStack(spacing: 16) {
                        // Spinner minimalista
                        MinimalSpinner()
                            .frame(width: 60, height: 60)
                    }
                }
            case .loaded:
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
                        ForEach(viewModel.generatedQuestions.indices, id: \.self) { index in
                            let question = viewModel.generatedQuestions[index]
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
        .onAppear {
            if let resumeFileURL {
                viewModel.generateQuestions(resumeURL: resumeFileURL, jobTitle: selectedJobTitle, seniority: selectedSeniority, description: jobDescription)
                return
            }
            
        }
        
    }
}
