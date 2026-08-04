//
//  DashboardSectionCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI

struct DashboardSectionCard<Content: View>:
    View {

    let title: String
    let icon: String

    @ViewBuilder let content: Content

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 16
        ) {
            Label(
                title,
                systemImage: icon
            )
            .font(.headline)
            .foregroundColor(.persianBlue)

            content
        }
        .padding()
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            Color(
                uiColor:
                    .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

struct DashboardEmptyContent: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .padding(.vertical, 20)
    }
}

struct ProgressDashboardLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)

            Text("Carregando seu progresso")
                .font(.headline)
                .foregroundColor(.persianBlue)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

struct ProgressDashboardErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(
                "Não foi possível carregar",
                systemImage:
                    "exclamationmark.triangle"
            )
        } description: {
            Text(message)
        } actions: {
            Button(
                "Tentar novamente",
                action: retryAction
            )
            .buttonStyle(.borderedProminent)
        }
    }
}
