//
//  VideoDetailView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import AVKit
import SwiftUI

struct VideoDetailView: View {
    let videoId: String

    @StateObject
    var coordinator: Coordinator

    @State
    private var video:
        TechVideo?

    @State
    private var isLoading =
        true

    private let service =
        VideoService()

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()

            } else if let video {
                VStack(
                    alignment: .leading,
                    spacing: 20
                ) {
                    if
                        video.status
                        == .approved,
                        let url =
                            video.streamURL {

                        VideoPlayer(
                            player:
                                AVPlayer(
                                    url: url
                                )
                        )
                        .frame(
                            height: 260
                        )
                    }

                    Text(
                        video.title
                    )
                    .font(
                        .title2.bold()
                    )

                    Text(
                        video.status.title
                    )

                    if let description =
                        video.description {

                        Text(
                            description
                        )
                    }

                    if
                        video.status
                        == .pending {

                        Label(
                            "Este vídeo está aguardando análise.",
                            systemImage:
                                "clock"
                        )
                        .foregroundStyle(
                            .orange
                        )
                    }

                    if
                        video.status
                        == .rejected,
                        let reason =
                            video.rejectionReason {

                        Label(
                            reason,
                            systemImage:
                                "xmark.circle"
                        )
                        .foregroundStyle(
                            .red
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle(
            "Vídeo"
        )
        .task {
            do {
                video =
                    try await service
                        .fetchVideo(
                            id:
                                videoId
                        )
            } catch {
                print(
                    "❌ \(error)"
                )
            }

            isLoading =
                false
        }
    }
}
