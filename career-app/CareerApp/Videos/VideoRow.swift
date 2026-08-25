//
//  VideoRow.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import SwiftUI

struct VideoRow: View {
    let video: TechVideo

    var body: some View {
        HStack(
            spacing: 16
        ) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    Color.persianBlue
                        .opacity(0.12)
                )

                if let thumbnailURL =
                    video.thumbnailURL {

                    AsyncImage(
                        url: thumbnailURL
                    ) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(
                            systemName:
                                "play.rectangle.fill"
                        )
                        .font(.title)
                        .foregroundStyle(
                            Color.persianBlue
                        )
                    }
                    .frame(
                        width: 80,
                        height: 70
                    )
                    .clipped()

                } else {
                    Image(
                        systemName:
                            "play.rectangle.fill"
                    )
                    .font(.title)
                    .foregroundStyle(
                        Color.persianBlue
                    )
                }
            }
            .frame(
                width: 80,
                height: 70
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14
                )
            )

            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                Text(video.title)
                    .font(
                        .headline
                    )

                Text(
                    video.status.title
                )
                .font(.caption)
                .foregroundStyle(
                    statusColor
                )

                if
                    video.status
                    == .rejected,
                    let reason =
                        video.rejectionReason {

                    Text(reason)
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(
                systemName:
                    "chevron.right"
            )
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }

    private var statusColor:
        Color {

        switch video.status {
        case .pending:
            return .orange

        case .approved:
            return .green

        case .rejected:
            return .red
        }
    }
}
