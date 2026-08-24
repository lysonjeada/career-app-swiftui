//
//  VideoServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class VideoServiceMock: VideoServiceProtocol {
    var isSuccess: Bool
    var videosToReturn: [TechVideo] = []
    var hasNextToReturn = false
    private(set) var receivedDeleteVideoId: String?
    private(set) var deleteCallCount = 0

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func fetchMyVideos(page: Int, pageSize: Int) async throws -> VideoPageResponse {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return VideoPageResponse(
            items: videosToReturn,
            page: page,
            pageSize: pageSize,
            total: videosToReturn.count,
            totalPages: 1,
            hasNext: hasNextToReturn
        )
    }

    func fetchApprovedVideos(page: Int, pageSize: Int) async throws -> VideoPageResponse {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return VideoPageResponse(
            items: videosToReturn,
            page: page,
            pageSize: pageSize,
            total: videosToReturn.count,
            totalPages: 1,
            hasNext: hasNextToReturn
        )
    }

    func fetchVideo(id: String) async throws -> TechVideo {
        guard isSuccess, let video = videosToReturn.first(where: { $0.id == id }) else {
            throw URLError(.badServerResponse)
        }

        return video
    }

    func uploadVideo(title: String, description: String, fileURL: URL) async throws -> TechVideo {
        guard isSuccess, let video = videosToReturn.first else {
            throw URLError(.badServerResponse)
        }

        return video
    }

    func deleteVideo(id: String) async throws {
        deleteCallCount += 1
        receivedDeleteVideoId = id

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }
    }
}

extension TechVideo {
    static func fixture(
        id: String = "video-1",
        userId: String = "user-1",
        title: String = "Vídeo de teste",
        status: VideoReviewStatus = .approved
    ) -> TechVideo {
        TechVideo(
            id: id,
            userId: userId,
            title: title,
            description: nil,
            status: status,
            rejectionReason: nil,
            createdAt: "2026-08-24T00:00:00Z",
            reviewedAt: nil,
            streamPath: nil
        )
    }
}
