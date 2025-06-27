//
//  ResumeFeedbackView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

struct ResumeFeedbackView: View {
    @StateObject var viewModel: ResumeFeedbackViewModel
    @State private var importing = false
    @State private var resumeFileURL: URL?
    @State private var didExportResume: Bool = false
    @State private var showingFeedbackSheet = false
    
    var body: some View {
        ScrollView {
            createView()
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            FeedbackSheetView(viewModel: viewModel)
        }
        .padding()
    }

    @ViewBuilder
    func createView() -> some View {
        VStack {
            Text("Faça o upload do seu currículo")
                .bold()
                .font(.system(size: 22))
                .foregroundColor(.thirdBlue)
                .padding(.bottom, 8)
            createButtonRow()
                .padding(.top, 4)
            Text("Iremos ler seu currículo e retornar o que poderia ser melhorado, estar mais claro, palavras-chave, etc")
                .font(.system(size: 16))
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal)
                .padding(.bottom, 16)
            if didExportResume {
                Button {
                    if let url = resumeFileURL {
                        viewModel.submitResumeFeedback(resumeURL: url)
                        
                        // Aguarda pequeno tempo e abre o sheet se tiver sucesso
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showingFeedbackSheet = true
                        }
                    }
                } label: {
                    Text("Enviar")
                        .padding()
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .animation(.easeInOut, value: didExportResume)
            }
        }
        
    }
    
    @ViewBuilder
    func createButtonRow() -> some View {
        Button(action: {
            importing = true
        }) {
            buttonContent()
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selected = urls.first {
                    resumeFileURL = selected
                    didExportResume = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
                        didExportResume = false
                    }
                }
            case .failure(let error):
                print("Erro ao importar arquivo:", error.localizedDescription)
            }
        }
    }

    @ViewBuilder
    private func buttonContent() -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.persianBlue)
                    .frame(width: 60, height: 60)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 4)
                
                Image(systemName: didExportResume ? "checkmark.circle.fill" : "square.and.arrow.up")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(didExportResume ? "Exportado!" : "")
                .bold()
                .font(.system(size: didExportResume ? 12 : 0))
                .foregroundColor(Color.white)
                .padding(.top, didExportResume ? 4 : 0)
                .padding(.bottom, didExportResume ? 8 : 4)
        }
    }
}

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
                        if let feedback = viewModel.feedbackText {
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



//struct FeedbackSheetView: View {
//    @StateObject var viewModel: ResumeFeedbackViewModel
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                switch viewModel.viewState {
//                case .loading:
//                    ProgressView("Analisando currículo...")
//                        .padding()
//                case .loaded:
//                    Text("💬 Feedback:")
//                        .font(.headline)
//                        .padding(.top)
//                    Text(viewModel.feedbackText ?? "")
//                        .font(.body)
//                        .padding()
//                case .error:
//                    Text("Erro")
//                        .foregroundColor(.red)
//                }
//            }
//            .navigationTitle("Feedback do Currículo")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
