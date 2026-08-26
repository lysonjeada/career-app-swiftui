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
    private var loadErrorMessage:
        String?

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

    @State
    private var isReacting =
        false

    @State
    private var reactionErrorMessage:
        String?

    @State
    private var isTogglingFavorite =
        false

    @State
    private var favoriteErrorMessage:
        String?

    /// Criado uma única vez (não a cada re-render do body) e
    /// pausado antes de ser liberado — construir um `AVPlayer` novo
    /// inline no body (como antes) recria a conexão de rede a cada
    /// mudança de @State nesta tela, e derrubar um AVPlayer preso
    /// carregando/bufferizando trava a thread principal por vários
    /// segundos quando a tela é fechada (a "tela preta" ao voltar).
    @State
    private var player:
        AVPlayer?

    private let service:
        VideoServiceProtocol =
        VideoService()

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 80)

            } else if let loadErrorMessage {
                VStack(spacing: 12) {
                    Image(
                        systemName:
                            "exclamationmark.triangle"
                    )
                    .font(.largeTitle)
                    .foregroundStyle(.orange)

                    Text(loadErrorMessage)
                        .multilineTextAlignment(
                            .center
                        )
                        .foregroundStyle(.secondary)

                    Button("Tentar novamente") {
                        Task {
                            await loadVideo()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 80)
                .padding(.horizontal, 24)

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
                            player: player
                        )
                        .frame(
                            height: 260
                        )
                        .onAppear {
                            if player == nil {
                                player = AVPlayer(
                                    url: url
                                )
                            }
                        }
                    }

                    if isOwner(of: video) {
                        thumbnailSection(
                            for: video
                        )
                    }

                    Text(
                        video.title
                    )
                    .font(
                        .title2.bold()
                    )

                    if let description =
                        video.description {

                        Text(
                            description
                        )
                    }

                    if isOwner(of: video) {
                        Text(
                            video.status.title
                        )

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

                    } else {
                        reactionSection(
                            for: video
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
            // Pausar antes de soltar a referência evita que o
            // AVPlayer siga tentando bufferizar em segundo plano
            // enquanto é desalocado — é isso que travava a thread
            // principal por vários segundos ao sair da tela.
            player?.pause()
            player = nil

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
            await loadVideo()
        }
    }

    @MainActor
    private func loadVideo() async {
        isLoading = true
        loadErrorMessage = nil

        do {
            video =
                try await service
                    .fetchVideo(
                        id: videoId
                    )

        } catch {
            print(
                "❌ \(error)"
            )

            loadErrorMessage =
                error.localizedDescription
        }

        isLoading = false
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

            if isOwner(of: video) {
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
    }

    /// Só quem enviou o vídeo pode trocar a thumbnail — mesma regra
    /// que já vale para excluir o vídeo no backend.
    private func isOwner(
        of video: TechVideo
    ) -> Bool {
        guard let currentUserId =
            AuthSession.shared.userId
        else {
            return false
        }

        return video.userId == currentUserId
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

    @ViewBuilder
    private func reactionSection(
        for video: TechVideo
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack(spacing: 24) {
                Button {
                    Task {
                        await toggleReaction(.like)
                    }
                } label: {
                    Label(
                        "\(video.likesCount)",
                        systemImage:
                            video.myReaction == .like
                            ? "hand.thumbsup.fill"
                            : "hand.thumbsup"
                    )
                }
                .tint(
                    video.myReaction == .like
                        ? Color.persianBlue
                        : .secondary
                )

                Button {
                    Task {
                        await toggleReaction(.dislike)
                    }
                } label: {
                    Label(
                        "\(video.dislikesCount)",
                        systemImage:
                            video.myReaction == .dislike
                            ? "hand.thumbsdown.fill"
                            : "hand.thumbsdown"
                    )
                }
                .tint(
                    video.myReaction == .dislike
                        ? .red
                        : .secondary
                )

                Spacer()

                Button {
                    Task {
                        await toggleFavorite()
                    }
                } label: {
                    Image(
                        systemName:
                            video.isFavorited
                            ? "star.fill"
                            : "star"
                    )
                }
                .tint(
                    video.isFavorited
                        ? .yellow
                        : .secondary
                )
            }
            .disabled(
                isReacting || isTogglingFavorite
            )
            .font(.title3)

            if let reactionErrorMessage {
                Text(reactionErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let favoriteErrorMessage {
                Text(favoriteErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @MainActor
    private func toggleReaction(
        _ reaction: VideoReactionType
    ) async {
        guard let video else {
            return
        }

        isReacting = true
        reactionErrorMessage = nil

        do {
            let updatedVideo =
                video.myReaction == reaction
                ? try await service.removeReaction(
                    videoId: video.id
                )
                : try await service.setReaction(
                    videoId: video.id,
                    reaction: reaction
                )

            self.video = updatedVideo

        } catch {
            reactionErrorMessage =
                error.localizedDescription
        }

        isReacting = false
    }

    @MainActor
    private func toggleFavorite() async {
        guard let video else {
            return
        }

        isTogglingFavorite = true
        favoriteErrorMessage = nil

        do {
            let updatedVideo =
                video.isFavorited
                ? try await service.removeFavorite(
                    videoId: video.id
                )
                : try await service.addFavorite(
                    videoId: video.id
                )

            self.video = updatedVideo

        } catch {
            favoriteErrorMessage =
                error.localizedDescription
        }

        isTogglingFavorite = false
    }
}
