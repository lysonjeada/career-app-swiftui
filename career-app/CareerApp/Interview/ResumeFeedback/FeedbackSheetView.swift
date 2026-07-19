//
//  FeedbackSheetView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 28/07/25.
//

import SwiftUI

struct FeedbackSheetView: View {
    @StateObject var viewModel: ResumeFeedbackViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch viewModel.viewState {
                    case .loading:
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Enviando currículo...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)

                    case .polling:
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Analisando currículo...\nIsso pode levar alguns minutos.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)

                    case .loaded:
                        if let feedback = viewModel.response?.feedback {
                            Text("💬 Feedback:")
                                .font(.headline)
                                .padding(.bottom, 4)

                            Text(feedback)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .lineLimit(nil)
                        } else {
                            Text("Nenhum feedback disponível.")
                                .foregroundColor(.gray)
                        }

                    case .error:
                        VStack(spacing: 12) {
                            Image(systemName: "xmark.octagon.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 40))
                            Text("Ocorreu um erro ao gerar o feedback.")
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)

                    case .idle:
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationTitle("Feedback do Currículo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
