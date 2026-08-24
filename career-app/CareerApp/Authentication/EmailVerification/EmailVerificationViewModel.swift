//
//  EmailVerificationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

import Foundation

@MainActor
final class EmailVerificationViewModel:
    ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case verified
        case error
    }

    @Published private(set) var viewState:
        State = .idle

    @Published var code = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published private(set)
    var resendRemainingSeconds = 60

    private let email: String

    private let service:
        EmailVerificationServiceProtocol

    private var verificationTask:
        Task<Void, Never>?

    private var countdownTask:
        Task<Void, Never>?

    var canVerify: Bool {
        code.count == 6
        && code.allSatisfy(\.isNumber)
        && viewState != .loading
    }

    var canResend: Bool {
        resendRemainingSeconds == 0
        && viewState != .loading
    }

    init(
        email: String,
        service:
            EmailVerificationServiceProtocol =
            EmailVerificationService()
    ) {
        self.email = email
        self.service = service

        startCountdown(
            seconds: 60
        )
    }

    func updateCode(
        _ value: String
    ) {
        code = String(
            value
                .filter(\.isNumber)
                .prefix(6)
        )

        errorMessage = nil
    }

    func verify() {
        guard canVerify else {
            errorMessage = (
                "Digite o código de seis dígitos."
            )
            return
        }

        verificationTask?.cancel()

        viewState = .loading
        errorMessage = nil
        successMessage = nil

        let submittedCode = code

        verificationTask = Task {
            do {
                let response =
                    try await service.verifyEmail(
                        email: email,
                        code: submittedCode
                    )

                guard !Task.isCancelled else {
                    return
                }

                successMessage =
                    response.message

                viewState = .verified

            } catch is CancellationError {
                return

            } catch {
                errorMessage =
                    error.localizedDescription

                viewState = .error
            }
        }
    }

    func resendCode() {
        guard canResend else {
            return
        }

        verificationTask?.cancel()

        viewState = .loading
        errorMessage = nil
        successMessage = nil

        verificationTask = Task {
            do {
                let response =
                    try await service.resendCode(
                        email: email
                    )

                guard !Task.isCancelled else {
                    return
                }

                successMessage =
                    response.message

                code = ""
                viewState = .idle

                startCountdown(
                    seconds:
                        response.retryAfterSeconds
                )

            } catch is CancellationError {
                return

            } catch {
                errorMessage =
                    error.localizedDescription

                viewState = .error
            }
        }
    }

    private func startCountdown(
        seconds: Int
    ) {
        countdownTask?.cancel()

        resendRemainingSeconds =
            max(0, seconds)

        countdownTask = Task {
            while (
                resendRemainingSeconds > 0
                && !Task.isCancelled
            ) {
                try? await Task.sleep(
                    for: .seconds(1)
                )

                guard !Task.isCancelled else {
                    return
                }

                resendRemainingSeconds -= 1
            }
        }
    }

    deinit {
        verificationTask?.cancel()
        countdownTask?.cancel()
    }
}
