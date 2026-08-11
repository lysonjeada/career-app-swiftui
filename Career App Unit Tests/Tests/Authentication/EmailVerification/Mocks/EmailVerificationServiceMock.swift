//
//  EmailVerificationServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class EmailVerificationServiceMock: EmailVerificationServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedVerifyEmail: String?
    private(set) var receivedCode: String?
    private(set) var receivedResendEmail: String?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func verifyEmail(email: String, code: String) async throws -> EmailVerificationResponse {
        receivedVerifyEmail = email
        receivedCode = code

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("email-verification-response")
    }

    func resendCode(email: String) async throws -> ResendEmailVerificationResponse {
        receivedResendEmail = email

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("resend-email-verification-response")
    }
}
