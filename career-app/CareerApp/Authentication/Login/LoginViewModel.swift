//
//  LoginViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: State = .idle

    @Published var showSnackbar = false
    @Published var snackbarMessage = ""
    @Published var snackbarType: SnackbarType = .info

    @Published private(set)
    var loggedInUser: AuthenticationLoginResponse?

    @Published private(set)
    var pendingVerificationEmail: String?

    private var task: Task<Void, Never>?

    private let service: AuthenticationServiceProtocol

    private let emailVerificationService:
        EmailVerificationServiceProtocol

    init(
        service: AuthenticationServiceProtocol =
            AuthenticationService(),
        emailVerificationService:
            EmailVerificationServiceProtocol =
            EmailVerificationService()
    ) {
        self.service = service
        self.emailVerificationService =
            emailVerificationService
    }
    
    // MARK: - Business Logic
    func performLogin(
        username: String,
        password: String
    ) {
        let normalizedUsername =
            username.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedUsername.isEmpty,
              !password.isEmpty
        else {
            showSnackbar(
                message: "Preencha usuário e senha.",
                type: .info
            )
            return
        }

        task?.cancel()

        pendingVerificationEmail = nil
        loggedInUser = nil
        viewState = .loading

        task = Task {
            do {
                let response =
                    try await service.fetchLogin(
                        requestBody: .init(
                            username: normalizedUsername,
                            password: password
                        )
                    )

                loggedInUser = response
                viewState = .loaded

            } catch let error
                as AuthenticationServiceError {

                switch error {
                case let .emailNotVerified(
                    email,
                    message
                ):
                    await handleUnverifiedEmail(
                        email: email,
                        fallbackMessage: message
                    )

                default:
                    viewState = .error

                    showSnackbar(
                        message:
                            error.localizedDescription,
                        type: .error
                    )
                }

            } catch {
                viewState = .error

                showSnackbar(
                    message: error.localizedDescription,
                    type: .error
                )
            }
        }
    }
    
    private func handleUnverifiedEmail(
        email: String,
        fallbackMessage: String
    ) async {
        var feedbackMessage = fallbackMessage
        var feedbackType: SnackbarType = .info

        do {
            let response =
                try await emailVerificationService
                    .resendCode(
                        email: email
                    )

            feedbackMessage = response.message
            feedbackType = .success

        } catch {
            /*
             Mesmo que o backend retorne 429 porque um código
             foi enviado há menos de 60 segundos, o usuário
             ainda deve acessar a tela de verificação e usar
             o código anterior.
             */
            feedbackMessage =
                error.localizedDescription

            feedbackType = .info
        }

        viewState = .idle

        showSnackbar(
            message: feedbackMessage,
            type: feedbackType
        )

        /*
         Deve ser definido por último, pois essa mudança
         dispara a navegação para a tela de verificação.
         */
        pendingVerificationEmail = email
    }
    
    func clearPendingVerificationEmail() {
        pendingVerificationEmail = nil
    }
    
    // MARK: - Snackbar Helper
    private func showSnackbar(
        message: String,
        type: SnackbarType
    ) {
        snackbarMessage = message
        snackbarType = type
        showSnackbar = true

        Task {
            try? await Task.sleep(
                for: .seconds(3)
            )

            guard snackbarMessage == message else {
                return
            }

            showSnackbar = false
        }
    }

    deinit {
        task?.cancel()
    }
}
