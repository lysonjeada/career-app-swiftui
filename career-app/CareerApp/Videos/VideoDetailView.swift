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
    @StateObject
    private var viewModel: VideoDetailViewModel

    @State
    private var selectedThumbnailItem:
        PhotosPickerItem?

    /// Criado uma única vez (não a cada re-render do body) e
    /// pausado antes de ser liberado — construir um `AVPlayer` novo
    /// inline no body (como antes) recria a conexão de rede a cada
    /// mudança de @State nesta tela, e derrubar um AVPlayer preso
    /// carregando/bufferizando trava a thread principal por vários
    /// segundos quando a tela é fechada (a "tela preta" ao voltar).
    @State
    private var player:
        AVPlayer?

    init(
        videoId: String
    ) {
        self._viewModel = StateObject(
            wrappedValue:
                VideoDetailViewModel(
                    videoId: videoId
                )
        )
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 80)

            } else if let loadErrorMessage = viewModel.loadErrorMessage {
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
                            await viewModel.loadVideo()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 80)
                .padding(.horizontal, 24)

            } else if let video = viewModel.video {
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

                    if viewModel.isOwner {
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

                    if viewModel.isOwner {
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

                await viewModel.updateThumbnail(
                    imageData: data
                )
            }
        }
        .task {
            await viewModel.loadVideo()
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
                        await viewModel.resendReviewNotification()
                    }
                } label: {
                    if viewModel.isResending {
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
                    viewModel.isResending
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

            if let resendMessage = viewModel.resendMessage {
                Text(resendMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .green
                    )
            }

            if let resendErrorMessage = viewModel.resendErrorMessage {
                Text(resendErrorMessage)
                    .font(.caption)
                    .foregroundStyle(
                        .red
                    )
            }
        }
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

                if viewModel.isUpdatingThumbnail {
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

            if viewModel.isOwner {
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
                    viewModel.isUpdatingThumbnail
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

                if let thumbnailErrorMessage = viewModel.thumbnailErrorMessage {
                    Text(thumbnailErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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
                        await viewModel.resendThumbnailReview()
                    }
                } label: {
                    if viewModel.isResendingThumbnail {
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
                .disabled(viewModel.isResendingThumbnail)

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

            if let thumbnailResendMessage = viewModel.thumbnailResendMessage {
                Text(thumbnailResendMessage)
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            if let thumbnailResendErrorMessage = viewModel.thumbnailResendErrorMessage {
                Text(thumbnailResendErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
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
                        await viewModel.toggleReaction(.like)
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
                        await viewModel.toggleReaction(.dislike)
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
                        await viewModel.toggleFavorite()
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
                viewModel.isReacting || viewModel.isTogglingFavorite
            )
            .font(.title3)

            if let reactionErrorMessage = viewModel.reactionErrorMessage {
                Text(reactionErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let favoriteErrorMessage = viewModel.favoriteErrorMessage {
                Text(favoriteErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}
