//
//  VideoDetailView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import AVKit
import PhotosUI
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

    @State
    private var selectedThumbnailItem:
        PhotosPickerItem?

    @State
    private var isUpdatingThumbnail =
        false

    @State
    private var thumbnailErrorMessage:
        String?

    @State
    private var isResendingThumbnail =
        false

    @State
    private var thumbnailResendMessage:
        String?

    @State
    private var thumbnailResendErrorMessage:
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

                    thumbnailSection(
                        for: video
                    )

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
        .onChange(
            of: selectedThumbnailItem
        ) {
            _,
            item in

            guard let item
            else {
                return
            }

            Task {
                guard let data =
                    try? await item
                        .loadTransferable(
                            type: Data.self
                        )
                else {
                    return
                }

                await updateThumbnail(
                    imageData: data
                )
            }
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

    @ViewBuilder
    private func thumbnailSection(
        for video: TechVideo
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
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
                        ProgressView()
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .frame(height: 180)
                    .clipped()

                } else {
                    Image(
                        systemName:
                            "photo"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(
                        Color.persianBlue
                    )
                    .frame(height: 180)
                }

                if isUpdatingThumbnail {
                    Color.black
                        .opacity(0.35)

                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14
                )
            )

            PhotosPicker(
                selection:
                    $selectedThumbnailItem,
                matching: .images
            ) {
                Label(
                    "Editar thumbnail",
                    systemImage:
                        "photo.badge.plus"
                )
            }
            .disabled(
                isUpdatingThumbnail
            )

            if video.thumbnailStatus == .pending {
                Label(
                    "Sua nova thumbnail está aguardando análise.",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(.orange)

                thumbnailResendSection(
                    for: video
                )
            }

            if
                video.thumbnailStatus == .rejected,
                let reason =
                    video.thumbnailRejectionReason {

                Label(
                    reason,
                    systemImage:
                        "xmark.circle"
                )
                .font(.caption)
                .foregroundStyle(.red)
            }

            if let thumbnailErrorMessage {
                Text(thumbnailErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private func thumbnailResendSection(
        for video: TechVideo
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 6
        ) {
            if video.canResendThumbnailReview {
                Button {
                    Task {
                        await resendThumbnailReview()
                    }
                } label: {
                    if isResendingThumbnail {
                        ProgressView()
                    } else {
                        Label(
                            "Reenviar notificação de revisão",
                            systemImage:
                                "envelope.arrow.triangle.branch"
                        )
                    }
                }
                .buttonStyle(.bordered)
                .tint(.persianBlue)
                .disabled(isResendingThumbnail)

            } else if let nextDate =
                video.thumbnailNextResendAllowedDate {

                HStack(spacing: 4) {
                    Text(
                        "Você poderá reenviar novamente"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Text(nextDate, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let thumbnailResendMessage {
                Text(thumbnailResendMessage)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if let thumbnailResendErrorMessage {
                Text(thumbnailResendErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @MainActor
    private func updateThumbnail(
        imageData: Data
    ) async {
        isUpdatingThumbnail = true
        thumbnailErrorMessage = nil

        do {
            let updatedVideo =
                try await service
                    .updateThumbnail(
                        id: videoId,
                        imageData: imageData
                    )

            video = updatedVideo

        } catch {
            thumbnailErrorMessage =
                error.localizedDescription
        }

        isUpdatingThumbnail = false
    }

    @MainActor
    private func resendThumbnailReview() async {
        guard let video else {
            return
        }

        isResendingThumbnail = true
        thumbnailResendMessage = nil
        thumbnailResendErrorMessage = nil

        do {
            let updatedVideo =
                try await service
                    .resendThumbnailReviewNotification(
                        id: video.id
                    )

            self.video = updatedVideo

            thumbnailResendMessage =
                "Notificação reenviada com sucesso."

        } catch {
            thumbnailResendErrorMessage =
                error.localizedDescription
        }

        isResendingThumbnail = false
    }
}
