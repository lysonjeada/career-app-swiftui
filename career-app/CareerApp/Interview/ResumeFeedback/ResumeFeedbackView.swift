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
    @State private var isLoading = false
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
            updateLoadingState()
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

    private func updateLoadingState() {
        switch viewModel.viewState {
        case .loaded:
            showReadyAlert = true
            isLoading = false

        case .loading, .polling:
            isLoading = true

        case .idle:
            isLoading = false
        case .error:
            isLoading = false
        }
    }
}
