//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct InterviewSimulationSessionView: View {
    @ObservedObject var viewModel:
        InterviewSimulationViewModel

    @StateObject private var audioRecorder =
        AudioRecorderManager()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    SimulationProgressHeader(
                        currentQuestion: viewModel.currentIndex + 1,
                        totalQuestions: viewModel.questions.count,
                        progress: viewModel.progress,
                        elapsedTime:
                            viewModel.formattedElapsedTime
                    )

                    if let question = viewModel.currentQuestion {
                        SimulationQuestionCard(
                            question: question.text
                        )
                    }

                    answerTypePicker

                    switch viewModel.answerInputType {
                    case .text:
                        SimulationTextAnswerView(
                            answer: $viewModel.currentAnswer
                        )

                    case .audio:
                        SimulationAudioAnswerView(
                            recorder: audioRecorder
                        )
                    }
                }
                .padding()
            }

            submitButton
        }
        .overlay {
            if viewModel.state == .transcribing {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()

                        Text("Transcrevendo áudio...")
                            .font(.headline)
                    }
                    .padding(24)
                    .background(.regularMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
            }
        }
        .onChange(of: viewModel.answerInputType) { newValue in
            if newValue == .text {
                audioRecorder.reset()
            }
        }
        .alert(
            "Erro no áudio",
            isPresented: Binding(
                get: {
                    audioRecorder.errorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        audioRecorder.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                audioRecorder.errorMessage = nil
            }
        } message: {
            Text(audioRecorder.errorMessage ?? "")
        }
    }

    private var answerTypePicker: some View {
        Picker(
            "Forma de resposta",
            selection: $viewModel.answerInputType
        ) {
            ForEach(InterviewAnswerInputType.allCases) { type in
                Label(
                    type.title,
                    systemImage: type.icon
                )
                .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .disabled(audioRecorder.isRecording)
    }

    private var submitButton: some View {
        Button {
            Task {
                switch viewModel.answerInputType {
                case .text:
                    await viewModel.submitTextAnswer()

                case .audio:
                    let fileURL: URL?

                    if audioRecorder.isRecording {
                        fileURL = audioRecorder.stopRecording()
                    } else {
                        fileURL = audioRecorder.recordedFileURL
                    }

                    guard let fileURL else {
                        viewModel.showError(
                            "Grave uma resposta antes de continuar."
                        )
                        return
                    }

                    await viewModel.submitAudioAnswer(
                        fileURL: fileURL
                    )

                    audioRecorder.reset()
                }
            }
        } label: {
            Text(
                viewModel.isLastQuestion
                    ? "Finalizar entrevista"
                    : "Próxima pergunta"
            )
            .bold()
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color.persianBlue)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
        .disabled(
            viewModel.state == .transcribing
        )
        .padding()
        .background(Color.white)
    }
}
