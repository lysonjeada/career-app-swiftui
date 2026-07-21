//
//  Untitled.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct SimulationTextField: View {
    let title: String
    let placeholder: String

    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.persianBlue)

            TextField(
                placeholder,
                text: $text
            )
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color.persianBlue,
                        lineWidth: 1
                    )
            }
        }
    }
}

struct SimulationMenuField: View {
    let title: String

    @Binding var selectedItem: String

    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.persianBlue)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selectedItem = option
                    }
                }
            } label: {
                HStack {
                    Text(selectedItem)

                    Spacer()

                    Image(systemName: "chevron.down")
                }
                .foregroundColor(.persianBlue)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue,
                            lineWidth: 1
                        )
                }
            }
        }
    }
}

struct SimulationDescriptionField: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descrição da vaga")
                .font(.headline)
                .foregroundColor(.persianBlue)

            Text("Opcional")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $text)
                .frame(minHeight: 130)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue,
                            lineWidth: 1
                        )
                }
        }
    }
}

struct SimulationProgressHeader: View {
    let currentQuestion: Int
    let totalQuestions: Int
    let progress: Double
    let elapsedTime: String

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(
                    "Pergunta \(currentQuestion) de \(totalQuestions)"
                )
                .font(.headline)
                .foregroundColor(.persianBlue)

                Spacer()

                Label(
                    elapsedTime,
                    systemImage: "timer"
                )
                .font(.subheadline)
                .foregroundColor(.persianBlue)
            }

            ProgressView(value: progress)
                .tint(.persianBlue)
        }
    }
}

struct SimulationQuestionCard: View {
    let question: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "questionmark.bubble.fill")
                .font(.title2)
                .foregroundColor(.persianBlue)

            Text(question)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding()
        .background(
            Color.persianBlue.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct SimulationTextAnswerView: View {
    @Binding var answer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sua resposta")
                .font(.headline)

            TextEditor(text: $answer)
                .frame(minHeight: 180)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.persianBlue.opacity(0.7),
                            lineWidth: 1
                        )
                }
        }
    }
}

struct SimulationAudioAnswerView: View {
    @ObservedObject var recorder:
        AudioRecorderManager

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        recorder.isRecording
                            ? Color.red
                            : Color.persianBlue
                    )
                    .frame(width: 90, height: 90)

                Image(
                    systemName: recorder.isRecording
                        ? "stop.fill"
                        : "mic.fill"
                )
                .font(.system(size: 32))
                .foregroundColor(.white)
            }
            .onTapGesture {
                if recorder.isRecording {
                    recorder.stopRecording()
                } else {
                    Task {
                        await recorder.startRecording()
                    }
                }
            }

            Text(
                recorder.isRecording
                    ? "Gravando \(recorder.formattedDuration)"
                    : recorder.recordedFileURL == nil
                        ? "Toque para começar"
                        : "Áudio gravado"
            )
            .font(.headline)

            if recorder.recordedFileURL != nil &&
                !recorder.isRecording {

                Button("Gravar novamente") {
                    recorder.reset()

                    Task {
                        await recorder.startRecording()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

struct SimulationLoadingView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(.persianBlue)

            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct SimulationEvaluationErrorView: View {
    let message: String
    let retryAction: () -> Void
    let restartAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                "Não foi possível avaliar",
                systemImage: "exclamationmark.triangle"
            )
        } description: {
            Text(message)
        } actions: {
            Button(
                "Tentar novamente",
                action: retryAction
            )
            .buttonStyle(.borderedProminent)

            Button(
                "Reiniciar entrevista",
                action: restartAction
            )
            .buttonStyle(.bordered)
        }
    }
}
