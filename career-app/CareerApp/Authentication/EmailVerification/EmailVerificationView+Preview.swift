//
//  EmailVerificationView+Preview.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

#if DEBUG

import SwiftUI

private final class
EmailVerificationServicePreview:
    EmailVerificationServiceProtocol {

    func verifyEmail(
        email: String,
        code: String
    ) async throws
        -> EmailVerificationResponse {

        try await Task.sleep(
            for: .milliseconds(500)
        )

        return EmailVerificationResponse(
            verified: true,
            message:
                "E-mail verificado com sucesso."
        )
    }

    func resendCode(
        email: String
    ) async throws
        -> ResendEmailVerificationResponse {

        return ResendEmailVerificationResponse(
            message:
                "Novo código enviado.",
            retryAfterSeconds: 60
        )
    }
}

#Preview("Verificação de e-mail") {
    NavigationStack {
        EmailVerificationView(
            email: "amaryllis@example.com",
            onVerified: {},
            goBack: {},
            service:
                EmailVerificationServicePreview()
        )
    }
}

#endif
