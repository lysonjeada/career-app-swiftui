//
//  VideosViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct VideosViewModelTests {
    @Test @MainActor
    func testDeleteVideo_Success_RemovesVideoFromList() async throws {
        // Arrange
        let video = TechVideo.fixture(id: "video-1")
        let otherVideo = TechVideo.fixture(id: "video-2")
        let service = VideoServiceMock(isSuccess: true)
        service.videosToReturn = [video, otherVideo]
        let viewModel = VideosViewModel(service: service)

        viewModel.fetchVideos()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Act
        viewModel.deleteVideo(video)
        try await awaitCondition(
            until: !viewModel.videos.contains(where: { $0.id == video.id }),
            timeout: 5.0
        )

        // Assert
        #expect(viewModel.videos.map(\.id) == ["video-2"])
        #expect(service.receivedDeleteVideoId == "video-1")
        #expect(service.deleteCallCount == 1)
        #expect(viewModel.deletionErrorMessage == nil)
    }

    @Test @MainActor
    func testDeleteVideo_WhenServiceFails_SetsDeletionErrorMessageAndKeepsVideo() async throws {
        // Arrange
        let video = TechVideo.fixture(id: "video-1")
        let service = VideoServiceMock(isSuccess: true)
        service.videosToReturn = [video]
        let viewModel = VideosViewModel(service: service)

        viewModel.fetchVideos()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Act
        service.isSuccess = false
        viewModel.deleteVideo(video)
        try await awaitCondition(
            until: viewModel.deletionErrorMessage != nil,
            timeout: 5.0
        )

        // Assert
        #expect(viewModel.deletionErrorMessage != nil)
        #expect(viewModel.videos.map(\.id) == ["video-1"])
    }

    @Test @MainActor
    func testClearDeletionError_ResetsErrorMessage() async throws {
        // Arrange
        let video = TechVideo.fixture(id: "video-1")
        let service = VideoServiceMock(isSuccess: false)
        let viewModel = VideosViewModel(service: service)

        viewModel.deleteVideo(video)
        try await awaitCondition(
            until: viewModel.deletionErrorMessage != nil,
            timeout: 5.0
        )

        // Act
        viewModel.clearDeletionError()

        // Assert
        #expect(viewModel.deletionErrorMessage == nil)
    }
}
