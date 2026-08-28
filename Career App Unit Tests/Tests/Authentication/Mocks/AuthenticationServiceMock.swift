//
//  AuthenticationServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class AuthenticationServiceMock: AuthenticationServiceProtocol {
    var isSuccess: Bool
    var errorToThrow: Error?
    private(set) var receivedRegisterRequest: AuthenticationRegisterRequest?
    private(set) var receivedLoginRequest: AuthenticationLoginRequest?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func createRegister(requestBody: AuthenticationRegisterRequest) async throws -> AuthenticationRegisterResponse {
        receivedRegisterRequest = requestBody

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("authentication-register-response")
    }

    func fetchLogin(requestBody: AuthenticationLoginRequest) async throws -> AuthenticationLoginResponse {
        receivedLoginRequest = requestBody

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("login-success-response")
    }
    
    func refreshToken(refreshToken: String) async throws -> TokenRefreshResponse {
        .init(accessToken: "", refreshToken: "", tokenType: "", expiresIn: 30)
    }

    // MARK: - Password reset

    private(set) var receivedForgotPasswordEmail: String?
    private(set) var receivedVerifyCodeEmail: String?
    private(set) var receivedVerifyCode: String?
    private(set) var receivedResetToken: String?
    private(set) var receivedNewPassword: String?

    var resetTokenToReturn = "mock-reset-token"

    func requestPasswordReset(
        email: String
    ) async throws -> ForgotPasswordResponse {
        receivedForgotPasswordEmail = email

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return ForgotPasswordResponse(
            message: "Se o e-mail estiver cadastrado, enviaremos um código."
        )
    }

    func verifyPasswordResetCode(
        email: String,
        code: String
    ) async throws -> VerifyPasswordResetCodeResponse {
        receivedVerifyCodeEmail = email
        receivedVerifyCode = code

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return VerifyPasswordResetCodeResponse(
            resetToken: resetTokenToReturn
        )
    }

    func resetPassword(
        resetToken: String,
        newPassword: String
    ) async throws -> ResetPasswordResponse {
        receivedResetToken = resetToken
        receivedNewPassword = newPassword

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return ResetPasswordResponse(
            message: "Senha redefinida com sucesso."
        )
    }
}
