//
//  ResumeFeedbackView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

import SwiftUI
import UniformTypeIdentifiers

struct ResumeFeedbackView: View {
    @StateObject var viewModel: ResumeFeedbackViewModel

    @State private var importing = false
    @State private var resumeFileURL: URL?
    @State private var didExportResume = false
    @State private var showingFeedbackSheet = false
    @State private var showReadyAlert = false

    private let fullText =
        "Enviando currículo...\nVocê será alertado quando for carregado"

    var body: some View {
        ResumeFeedbackCard(
            didExportResume: didExportResume,
            isLoading: isLoading,
            loadingText: fullText,
            selectedFileName: resumeFileURL?.lastPathComponent,
            importAction: {
                importing = true
            },
            submitAction: submitResume
        )
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
        .sheet(isPresented: $showingFeedbackSheet) {
            FeedbackSheetView(viewModel: viewModel)
        }
        .alert(
            "Feedback gerado!",
            isPresented: $showReadyAlert
        ) {
            Button("Ver agora") {
                showingFeedbackSheet = true
            }

            Button("Fechar", role: .cancel) {}
        } message: {
            Text(
                "Seu currículo foi analisado. Deseja visualizar o feedback?"
            )
        }
        .onChange(of: viewModel.viewState) {
            if case .loaded = viewModel.viewState {
                showReadyAlert = true
            }
        }
        .padding(.horizontal)
    }

    private func submitResume() {
        guard let resumeFileURL else {
            return
        }

        viewModel.submitResumeFeedback(
            resumeURL: resumeFileURL
        )
    }

    private func handleFileImport(
        _ result: Result<[URL], Error>
    ) {
        switch result {
        case let .success(urls):
            guard let selectedURL = urls.first else {
                return
            }

            resumeFileURL = selectedURL
            didExportResume = true

            DispatchQueue.main.asyncAfter(
                deadline: .now() + 16
            ) {
                didExportResume = false
            }

        case let .failure(error):
            print(
                "Erro ao importar arquivo:",
                error.localizedDescription
            )
        }
    }

    private var isLoading: Bool {
        switch viewModel.viewState {
        case .loading, .polling:
            return true
        case .idle, .loaded, .error, .insufficientCredits:
            return false
        }
    }
}
