//
//  VideoDetailViewModel.swift
//  career-app
//

import Foundation

@MainActor
final class VideoDetailViewModel: ObservableObject {
    let videoId: String

    @Published private(set) var video: TechVideo?

    @Published private(set) var isLoading = true
    @Published private(set) var loadErrorMessage: String?

    @Published private(set) var isResending = false
    @Published private(set) var resendMessage: String?
    @Published private(set) var resendErrorMessage: String?

    @Published private(set) var isUpdatingThumbnail = false
    @Published private(set) var thumbnailErrorMessage: String?

    @Published private(set) var isResendingThumbnail = false
    @Published private(set) var thumbnailResendMessage: String?
    @Published private(set) var thumbnailResendErrorMessage: String?

    @Published private(set) var isReacting = false
    @Published private(set) var reactionErrorMessage: String?

    @Published private(set) var isTogglingFavorite = false
    @Published private(set) var favoriteErrorMessage: String?

    private let service: VideoServiceProtocol

    init(
        videoId: String,
        service: VideoServiceProtocol = VideoService()
    ) {
        self.videoId = videoId
        self.service = service
    }

    /// Só quem enviou o vídeo pode trocar a thumbnail — mesma regra
    /// que já vale para excluir o vídeo no backend.
    var isOwner: Bool {
        guard
            let video,
            let currentUserId = AuthSession.shared.userId
        else {
            return false
        }

        return video.userId == currentUserId
    }

    func loadVideo() async {
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

    func resendReviewNotification() async {
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

    func updateThumbnail(
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

    func resendThumbnailReview() async {
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

    func toggleReaction(
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

    func toggleFavorite() async {
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
