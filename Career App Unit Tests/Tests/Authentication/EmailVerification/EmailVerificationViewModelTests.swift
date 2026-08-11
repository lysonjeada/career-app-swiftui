//
//  EmailVerificationViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct EmailVerificationViewModelTests {
    @Test @MainActor
    func testVerify_Success_SetsVerifiedStateAndSuccessMessage() async throws {
        // Arrange
        let service = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)
        viewModel.updateCode("123456")

        // Act
        viewModel.verify()
        try await awaitCondition(until: viewModel.viewState == .verified, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .verified)
        #expect(viewModel.successMessage == "E-mail verificado com sucesso.")
        #expect(service.receivedVerifyEmail == "usuario@email.com")
        #expect(service.receivedCode == "123456")
    }

    @Test @MainActor
    func testVerify_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = EmailVerificationServiceMock(isSuccess: false)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)
        viewModel.updateCode("123456")

        // Act
        viewModel.verify()
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        #expect(viewModel.errorMessage != nil)
    }

    @Test @MainActor
    func testVerify_WithIncompleteCode_SetsErrorMessageWithoutCallingService() async throws {
        // Arrange
        let service = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)
        viewModel.updateCode("123")

        // Act
        viewModel.verify()

        // Assert
        #expect(viewModel.viewState == .idle)
        #expect(viewModel.errorMessage == "Digite o código de seis dígitos.")
        #expect(service.receivedVerifyEmail == nil)
    }

    @Test @MainActor
    func testUpdateCode_FiltersNonNumericCharactersAndLimitsToSixDigits() async throws {
        // Arrange
        let service = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)

        // Act
        viewModel.updateCode("1a2b3c4d5e6f7g")

        // Assert
        #expect(viewModel.code == "123456")
    }

    @Test @MainActor
    func testCanVerify_ReturnsTrueOnlyForSixDigitNumericCode() async throws {
        // Arrange
        let service = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)

        // Act & Assert
        viewModel.updateCode("12345")
        #expect(!viewModel.canVerify)

        viewModel.updateCode("123456")
        #expect(viewModel.canVerify)
    }

    @Test @MainActor
    func testResendCode_WhileCountdownActive_DoesNothingAndDoesNotCallService() async throws {
        // Arrange — o countdown inicial de 60s bloqueia reenvios imediatos
        let service = EmailVerificationServiceMock(isSuccess: true)
        let viewModel = EmailVerificationViewModel(email: "usuario@email.com", service: service)

        // Act
        viewModel.resendCode()

        // Assert
        #expect(!viewModel.canResend)
        #expect(viewModel.viewState == .idle)
        #expect(service.receivedResendEmail == nil)
    }
}
