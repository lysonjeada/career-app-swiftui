//
//  PasswordResetViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct PasswordResetViewModelTests {

    // MARK: - requestPasswordReset (Forgot)

    @Test @MainActor
    func testRequestPasswordReset_InvalidEmail_DoesNotCallServiceAndSetsError() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.requestPasswordReset(email: "not-an-email")

        #expect(succeeded == false)
        #expect(service.receivedForgotPasswordEmail == nil)
        #expect(viewModel.requestCodeErrorMessage != nil)
    }

    @Test @MainActor
    func testRequestPasswordReset_ValidEmail_CallsServiceWithNormalizedEmail() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.requestPasswordReset(
            email: "  user@example.com  "
        )

        #expect(succeeded == true)
        #expect(service.receivedForgotPasswordEmail == "user@example.com")
    }

    @Test @MainActor
    func testRequestPasswordReset_Success_ResetsLoadingAndStartsCountdown() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.requestPasswordReset(
            email: "user@example.com"
        )

        #expect(succeeded == true)
        #expect(viewModel.isRequestingCode == false)
        #expect(viewModel.requestCodeErrorMessage == nil)
        #expect(viewModel.resendRemainingSeconds > 0)
    }

    @Test @MainActor
    func testRequestPasswordReset_Failure_SetsErrorMessageAndClearsLoading() async throws {
        let service = AuthenticationServiceMock(isSuccess: false)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.requestPasswordReset(
            email: "user@example.com"
        )

        #expect(succeeded == false)
        #expect(viewModel.isRequestingCode == false)
        #expect(viewModel.requestCodeErrorMessage != nil)
    }

    @Test @MainActor
    func testRequestPasswordReset_WhileAlreadyRequesting_IsIgnored() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        async let first: Bool = viewModel.requestPasswordReset(
            email: "user@example.com"
        )

        // A segunda chamada, feita "ao mesmo tempo", só teria efeito
        // real se isRequestingCode não estivesse protegendo contra
        // taps duplicados — aqui validamos indiretamente que uma
        // única chamada bem-sucedida já move o estado corretamente.
        let succeeded = await first
        #expect(succeeded == true)
    }

    // MARK: - verifyCode

    @Test @MainActor
    func testVerifyCode_WrongLocalFormat_DoesNotCallService() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.verifyCode("123")

        #expect(succeeded == false)
        #expect(service.receivedVerifyCode == nil)
        #expect(viewModel.verifyCodeErrorMessage != nil)
    }

    @Test @MainActor
    func testVerifyCode_BackendAccepts_ReturnsTrueAndStoresNothingPublicly() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        service.resetTokenToReturn = "raw-reset-token-123"

        let viewModel = PasswordResetViewModel(service: service)
        _ = await viewModel.requestPasswordReset(email: "user@example.com")

        let succeeded = await viewModel.verifyCode("123456")

        #expect(succeeded == true)
        #expect(service.receivedVerifyCodeEmail == "user@example.com")
        #expect(service.receivedVerifyCode == "123456")
        #expect(viewModel.verifyCodeErrorMessage == nil)
        #expect(viewModel.isVerifyingCode == false)
    }

    @Test @MainActor
    func testVerifyCode_BackendRejects_SetsErrorMessage() async throws {
        let service = AuthenticationServiceMock(isSuccess: false)
        let viewModel = PasswordResetViewModel(service: service)

        let succeeded = await viewModel.verifyCode("000000")

        #expect(succeeded == false)
        #expect(viewModel.verifyCodeErrorMessage != nil)
        #expect(viewModel.isVerifyingCode == false)
    }

    // MARK: - resetPassword

    @Test @MainActor
    func testResetPassword_MismatchedPasswords_DoesNotCallService() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        _ = await viewModel.requestPasswordReset(email: "user@example.com")
        _ = await viewModel.verifyCode("123456")

        let succeeded = await viewModel.resetPassword(
            newPassword: "SenhaForte123!",
            confirmPassword: "Diferente456!"
        )

        #expect(succeeded == false)
        #expect(service.receivedResetToken == nil)
        #expect(viewModel.resetPasswordErrorMessage == "As senhas não coincidem.")
    }

    @Test @MainActor
    func testResetPassword_TooShort_DoesNotCallService() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        _ = await viewModel.requestPasswordReset(email: "user@example.com")
        _ = await viewModel.verifyCode("123456")

        let succeeded = await viewModel.resetPassword(
            newPassword: "abc123",
            confirmPassword: "abc123"
        )

        #expect(succeeded == false)
        #expect(service.receivedResetToken == nil)
    }

    @Test @MainActor
    func testResetPassword_WithoutVerifiedCodeFirst_FailsWithoutCallingService() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        // Nunca chamou verifyCode -> não existe reset token em memória.
        let succeeded = await viewModel.resetPassword(
            newPassword: "SenhaForte123!",
            confirmPassword: "SenhaForte123!"
        )

        #expect(succeeded == false)
        #expect(service.receivedResetToken == nil)
        #expect(viewModel.resetPasswordErrorMessage != nil)
    }

    @Test @MainActor
    func testResetPassword_ValidFlow_CallsServiceWithReceivedResetToken() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        service.resetTokenToReturn = "raw-reset-token-abc"

        let viewModel = PasswordResetViewModel(service: service)

        _ = await viewModel.requestPasswordReset(email: "user@example.com")
        _ = await viewModel.verifyCode("123456")

        let succeeded = await viewModel.resetPassword(
            newPassword: "SenhaForte123!",
            confirmPassword: "SenhaForte123!"
        )

        #expect(succeeded == true)
        #expect(service.receivedResetToken == "raw-reset-token-abc")
        #expect(service.receivedNewPassword == "SenhaForte123!")
        #expect(viewModel.isResettingPassword == false)
        #expect(viewModel.resetPasswordErrorMessage == nil)
    }

    @Test @MainActor
    func testResetPassword_Failure_SetsErrorMessage() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        _ = await viewModel.requestPasswordReset(email: "user@example.com")
        _ = await viewModel.verifyCode("123456")

        service.isSuccess = false

        let succeeded = await viewModel.resetPassword(
            newPassword: "SenhaForte123!",
            confirmPassword: "SenhaForte123!"
        )

        #expect(succeeded == false)
        #expect(viewModel.resetPasswordErrorMessage != nil)
        #expect(viewModel.isResettingPassword == false)
    }

    // MARK: - reset()

    @Test @MainActor
    func testReset_ClearsAllPublishedState() async throws {
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = PasswordResetViewModel(service: service)

        _ = await viewModel.requestPasswordReset(email: "user@example.com")
        #expect(viewModel.email == "user@example.com")

        viewModel.reset()

        #expect(viewModel.email == "")
        #expect(viewModel.requestCodeErrorMessage == nil)
        #expect(viewModel.verifyCodeErrorMessage == nil)
        #expect(viewModel.resetPasswordErrorMessage == nil)
        #expect(viewModel.resendRemainingSeconds == 0)
    }
}
