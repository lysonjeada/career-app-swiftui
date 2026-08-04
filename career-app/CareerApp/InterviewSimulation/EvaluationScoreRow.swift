//
//  EvaluationScoreRow.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import SwiftUI

struct EvaluationScoreRow: View {
    let title: String
    let icon: String
    let score: Int

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label(
                    title,
                    systemImage: icon
                )
                .font(.headline)
                .foregroundStyle(.primary)

                Spacer()

                Text("\(score)/100")
                    .bold()
                    .foregroundColor(.persianBlue)
            }

            ProgressView(
                value: Double(score),
                total: 100
            )
            .tint(.persianBlue)
        }
        .padding()
        .background(
            Color(
                uiColor: .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}

private struct EvaluationTextSection: View {
    let title: String
    let icon: String
    let values: [String]

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Label(
                title,
                systemImage: icon
            )
            .font(.headline)
            .foregroundColor(.persianBlue)

            ForEach(values, id: \.self) { value in
                HStack(
                    alignment: .top,
                    spacing: 8
                ) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.secondary)
                        .padding(.top, 7)

                    Text(value)
                        .foregroundStyle(.primary)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Color(
                uiColor: .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}
