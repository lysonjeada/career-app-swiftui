//
//  ResumeFeedbackCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import SwiftUI

struct ResumeFeedbackCard: View {
    let didExportResume: Bool
    let isLoading: Bool
    let loadingText: String
    let selectedFileName: String?

    let importAction: () -> Void
    let submitAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if let selectedFileName, didExportResume {
                SelectedResumeFileView(
                    filename: selectedFileName
                )
                .transition(
                    .opacity.combined(
                        with: .move(edge: .top)
                    )
                )
            }

            if isLoading {
                ResumeFeedbackLoadingView(
                    text: loadingText
                )
                .transition(.opacity)
            } else {
                actionButtons
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 18
            )
            .stroke(
                Color.persianBlue.opacity(0.25),
                lineWidth: 1
            )
        }
        .shadow(
            color: Color.black.opacity(0.06),
            radius: 10,
            x: 0,
            y: 4
        )
        .animation(
            .easeInOut,
            value: didExportResume
        )
        .animation(
            .easeInOut,
            value: isLoading
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            ResumeFeedbackIcon(
                didExportResume: didExportResume
            )

            VStack(alignment: .leading, spacing: 7) {
                Text("Melhore seu currículo")
                    .font(.headline)
                    .foregroundColor(.persianBlue)

                Text(
                    """
                    Envie seu currículo para receber sugestões de melhorias, clareza e palavras-chave.
                    """
                )
                .font(.subheadline)
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.leading)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            Spacer(minLength: 0)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: importAction) {
                Label(
                    didExportResume
                        ? "Trocar currículo"
                        : "Selecionar currículo",
                    systemImage:
                        "square.and.arrow.up"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 13)
                .foregroundColor(
                    Color.persianBlue
                )
                .background {
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                    .stroke(
                        Color.persianBlue,
                        lineWidth: 1
                    )
                }
            }
            .buttonStyle(.plain)

            if didExportResume {
                Button(action: submitAction) {
                    Label(
                        "Enviar",
                        systemImage: "paperplane.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(.vertical, 13)
                    .foregroundColor(.white)
                    .background(
                        Color.persianBlue
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 12
                        )
                    )
                }
                .buttonStyle(.plain)
                .transition(
                    .opacity.combined(
                        with: .move(edge: .trailing)
                    )
                )
            }
        }
    }
}
