//
//  StudyPlanSection.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import SwiftUI

struct StudyPlanSection: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plano de estudos")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.persianBlue)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )

            NavigationLink {
                StudyPlanFlowView()
            } label: {
                StudyPlanLauncherCard()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
    }
}

private struct StudyPlanLauncherCard: View {

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        Color.persianBlue.opacity(0.12)
                    )
                    .frame(
                        width: 58,
                        height: 58
                    )

                Image(
                    systemName: "graduationcap.fill"
                )
                .font(.system(size: 25))
                .foregroundColor(.persianBlue)
            }

            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text("Criar plano de estudos")
                    .font(.headline)
                    .foregroundColor(.persianBlue)

                Text(
                    """
                    Gere uma trilha personalizada para a vaga desejada.
                    """
                )
                .font(.subheadline)
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color.persianBlue.opacity(0.25),
                    lineWidth: 1
                )
        }
    }
}
