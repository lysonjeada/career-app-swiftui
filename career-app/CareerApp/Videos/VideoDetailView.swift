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

    @State
    private var isResending =
        false

    @State
    private var resendMessage:
        String?

    @State
    private var resendErrorMessage:
        String?

    private let service:
        VideoServiceProtocol =
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

                        resendReviewSection(
                            for: video
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
        .onAppear {
            VideoPlaybackAudioSession
                .activate()
        }
        .onDisappear {
            VideoPlaybackAudioSession
                .deactivate()
        }
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

    @ViewBuilder
    private func resendReviewSection(
        for video: TechVideo
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            if video
                .canResendReviewNotification {

                Button {
                    Task {
                        await resendReviewNotification()
                    }
                } label: {
                    if isResending {
                        ProgressView()
                    } else {
                        Label(
                            "Reenviar notificação de revisão",
                            systemImage:
                                "envelope.arrow.triangle.branch"
                        )
                    }
                }
                .buttonStyle(
                    .bordered
                )
                .tint(.persianBlue)
                .disabled(
                    isResending
                )

            } else if let nextDate =
                video.nextResendAllowedDate {

                HStack(
                    spacing: 4
                ) {
                    Text(
                        "Você poderá reenviar novamente"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )

                    Text(
                        nextDate,
                        style: .relative
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }
            }

            if let resendMessage {
                Text(resendMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .green
                    )
            }

            if let resendErrorMessage {
                Text(resendErrorMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .red
                    )
            }
        }
    }

    @MainActor
    private func resendReviewNotification() async {
        guard let video else {
            return
        }

        isResending = true
        resendMessage = nil
        resendErrorMessage = nil

        do {
            let updatedVideo =
                try await service
                    .resendReviewNotification(
                        id: video.id
                    )

            self.video =
                updatedVideo

            resendMessage =
                "Notificação reenviada com sucesso."

        } catch {
            resendErrorMessage =
                error.localizedDescription
        }

        isResending = false
    }
}
