//
//  InterviewSimulationLauncherCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import SwiftUI

struct InterviewSimulationLauncherCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.persianBlue.opacity(0.12))
                    .frame(width: 58, height: 58)

                Image(systemName: "person.wave.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.persianBlue)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Simular entrevista")
                    .font(.headline)
                    .foregroundColor(.persianBlue)

                Text(
                    "Responda perguntas por texto ou áudio e receba uma avaliação."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white)
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
