//
//  ProfileViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct ProfileViewModelTests {
    @Test @MainActor
    func testFetchProfile_Success_PopulatesUserDataAndSetsViewStateLoaded() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: true)
        let viewModel = ProfileViewModel(service: service)

        // Act
        viewModel.fetchProfile(userId: "user-123")
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.username == "usuario_teste")
        #expect(viewModel.email == "usuario.teste@email.com")
        #expect(viewModel.loggedInUser?.accessToken == "token-de-teste")
        #expect(service.receivedFetchUserId == "user-123")
    }

    @Test @MainActor
    func testFetchProfile_WhenServiceFails_SetsViewStateError() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: false)
        let viewModel = ProfileViewModel(service: service)

        // Act
        viewModel.fetchProfile(userId: "user-123")
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        #expect(viewModel.loggedInUser == nil)
    }

    @Test @MainActor
    func testDeleteUser_Success_SetsDidDeleteUserTrue() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: true)
        let viewModel = ProfileViewModel(service: service)

        // Act
        viewModel.deleteUser(userId: "user-123")
        try await awaitCondition(until: viewModel.didDeleteUser, timeout: 5.0)

        // Assert
        #expect(viewModel.didDeleteUser)
        #expect(!viewModel.isDeletingUser)
        #expect(viewModel.deletionErrorMessage == nil)
        #expect(service.receivedDeleteUserId == "user-123")
    }

    @Test @MainActor
    func testDeleteUser_WhenServiceFails_SetsDeletionErrorMessage() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: false)
        let viewModel = ProfileViewModel(service: service)

        // Act
        viewModel.deleteUser(userId: "user-123")
        try await awaitCondition(until: viewModel.deletionErrorMessage != nil, timeout: 5.0)

        // Assert
        #expect(!viewModel.didDeleteUser)
        #expect(!viewModel.isDeletingUser)
        #expect(viewModel.deletionErrorMessage != nil)
    }

    @Test @MainActor
    func testDeleteUser_WithEmptyUserId_SetsErrorMessageWithoutCallingService() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: true)
        let viewModel = ProfileViewModel(service: service)

        // Act
        viewModel.deleteUser(userId: "   ")

        // Assert
        #expect(viewModel.deletionErrorMessage == "Não foi possível identificar o usuário.")
        #expect(service.receivedDeleteUserId == nil)
        #expect(!viewModel.didDeleteUser)
    }

    @Test @MainActor
    func testConsumeDeletionSuccess_ResetsDidDeleteUserFlag() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: true)
        let viewModel = ProfileViewModel(service: service)
        viewModel.deleteUser(userId: "user-123")
        try await awaitCondition(until: viewModel.didDeleteUser, timeout: 5.0)

        // Act
        viewModel.consumeDeletionSuccess()

        // Assert
        #expect(!viewModel.didDeleteUser)
    }

    @Test @MainActor
    func testClearDeletionError_ResetsErrorMessage() async throws {
        // Arrange
        let service = ProfileServiceMock(isSuccess: false)
        let viewModel = ProfileViewModel(service: service)
        viewModel.deleteUser(userId: "user-123")
        try await awaitCondition(until: viewModel.deletionErrorMessage != nil, timeout: 5.0)

        // Act
        viewModel.clearDeletionError()

        // Assert
        #expect(viewModel.deletionErrorMessage == nil)
    }
}
