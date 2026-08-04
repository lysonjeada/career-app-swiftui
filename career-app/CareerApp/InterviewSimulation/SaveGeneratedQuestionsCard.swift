//
//  SaveGeneratedQuestionsCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import SwiftUI

struct SaveGeneratedQuestionsCard: View {
    let questionsCount: Int
    let state: SaveGeneratedQuestionsState
    let saveAction: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            HStack(alignment: .top, spacing: 14) {
                icon

                VStack(alignment: .leading, spacing: 6) {
                    Text("Salvar perguntas")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if case let .error(message) = state {
                Label(
                    message,
                    systemImage: "exclamationmark.triangle.fill"
                )
                .font(.caption)
                .foregroundStyle(.red)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }

            Button(action: saveAction) {
                HStack {
                    if state == .saving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: buttonIcon)
                    }

                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .foregroundStyle(buttonForegroundColor)
                .background(buttonBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }
            .buttonStyle(.plain)
            .disabled(isButtonDisabled)
        }
        .padding()
        .background(
            Color(
                uiColor: .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    borderColor,
                    lineWidth: 1
                )
        }
    }

    @ViewBuilder
    private var icon: some View {
        ZStack {
            Circle()
                .fill(
                    Color.persianBlue.opacity(0.12)
                )
                .frame(width: 48, height: 48)

            Image(
                systemName: saved
                    ? "checkmark.circle.fill"
                    : "bookmark.fill"
            )
            .font(.system(size: 21))
            .foregroundStyle(Color.persianBlue)
        }
    }

    private var description: String {
        switch state {
        case .saved(let count):
            return "\(count) perguntas foram salvas com sucesso."

        default:
            return """
            Salve as \(questionsCount) perguntas geradas para consultar novamente depois.
            """
        }
    }

    private var buttonTitle: String {
        switch state {
        case .idle:
            return "Salvar perguntas"

        case .saving:
            return "Salvando..."

        case .saved:
            return "Perguntas salvas"

        case .error:
            return "Tentar salvar novamente"
        }
    }

    private var buttonIcon: String {
        switch state {
        case .saved:
            return "checkmark"

        case .error:
            return "arrow.clockwise"

        default:
            return "bookmark.fill"
        }
    }

    private var isButtonDisabled: Bool {
        switch state {
        case .saving, .saved:
            return true

        case .idle, .error:
            return false
        }
    }

    private var saved: Bool {
        if case .saved = state {
            return true
        }

        return false
    }

    private var buttonBackground: Color {
        saved
            ? Color.persianBlue.opacity(0.15)
            : Color.persianBlue
    }

    private var buttonForegroundColor: Color {
        saved
            ? Color.persianBlue
            : Color.white
    }

    private var borderColor: Color {
        saved
            ? Color.persianBlue
            : Color(
                uiColor: .separator
            )
    }
}
