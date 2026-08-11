//
//  LoginViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct LoginViewModelTests {
    @Test @MainActor
    func testPerformLogin_Success_SetsLoadedStateAndLoggedInUser() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)

        // Act
        viewModel.performLogin(username: "usuario_teste", password: "senha123")
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.loggedInUser?.username == "usuario_teste")
        #expect(viewModel.pendingVerificationEmail == nil)
        #expect(service.receivedLoginRequest?.username == "usuario_teste")
    }

    @Test @MainActor
    func testPerformLogin_WithEmptyFields_ShowsSnackbarWithoutCallingService() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)

        // Act
        viewModel.performLogin(username: "  ", password: "")

        // Assert
        #expect(viewModel.viewState == .idle)
        #expect(viewModel.snackbarMessage == "Preencha usuário e senha.")
        #expect(service.receivedLoginRequest == nil)
    }

    @Test @MainActor
    func testPerformLogin_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: false)
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)

        // Act
        viewModel.performLogin(username: "usuario_teste", password: "senha123")
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        #expect(viewModel.loggedInUser == nil)
    }

    @Test @MainActor
    func testPerformLogin_WhenEmailNotVerified_ResendsCodeAndSetsPendingVerificationEmail() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        service.errorToThrow = AuthenticationServiceError.emailNotVerified(
            email: "usuario@email.com",
            message: "Confirme seu e-mail para continuar."
        )
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)

        // Act
        viewModel.performLogin(username: "usuario_teste", password: "senha123")
        try await awaitCondition(until: viewModel.pendingVerificationEmail != nil, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .idle)
        #expect(viewModel.pendingVerificationEmail == "usuario@email.com")
        #expect(emailVerificationService.receivedResendEmail == "usuario@email.com")
        #expect(viewModel.snackbarMessage == "Código reenviado com sucesso.")
    }

    @Test @MainActor
    func testPerformLogin_WhenEmailNotVerifiedAndResendFails_StillSetsPendingVerificationEmail() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        service.errorToThrow = AuthenticationServiceError.emailNotVerified(
            email: "usuario@email.com",
            message: "Confirme seu e-mail para continuar."
        )
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: false)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)

        // Act
        viewModel.performLogin(username: "usuario_teste", password: "senha123")
        try await awaitCondition(until: viewModel.pendingVerificationEmail != nil, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .idle)
        #expect(viewModel.pendingVerificationEmail == "usuario@email.com")
    }

    @Test @MainActor
    func testClearPendingVerificationEmail_ResetsToNil() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        service.errorToThrow = AuthenticationServiceError.emailNotVerified(
            email: "usuario@email.com",
            message: "Confirme seu e-mail para continuar."
        )
        let emailVerificationService = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = LoginViewModel(service: service, emailVerificationService: emailVerificationService)
        viewModel.performLogin(username: "usuario_teste", password: "senha123")
        try await awaitCondition(until: viewModel.pendingVerificationEmail != nil, timeout: 5.0)

        // Act
        viewModel.clearPendingVerificationEmail()

        // Assert
        #expect(viewModel.pendingVerificationEmail == nil)
    }
}
