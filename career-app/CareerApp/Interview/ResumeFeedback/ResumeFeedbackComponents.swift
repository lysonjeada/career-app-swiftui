//
//  ResumeFeedbackComponents.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import SwiftUI

struct SelectedResumeFileView: View {
    let filename: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.fill")
                .foregroundColor(
                    Color.persianBlue
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Currículo selecionado")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(filename)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()

            Image(
                systemName: "checkmark.circle.fill"
            )
            .foregroundColor(
                Color.persianBlue
            )
        }
        .padding(12)
        .background(
            Color.persianBlue.opacity(0.07)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }
}

struct ResumeFeedbackLoadingView: View {
    let text: String

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.regular)
                .tint(
                    Color.persianBlue
                )

            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
