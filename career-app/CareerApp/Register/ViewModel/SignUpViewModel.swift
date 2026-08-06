//
//  SignUpViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error
    }

    @Published private(set) var viewState: State = .idle

    @Published private(set) var registeredEmail: String?

    @Published var showSnackbar = false
    @Published var snackbarMessage = ""
    @Published var snackbarType: SnackbarType = .info

    private var task: Task<Void, Never>?

    private let service: AuthenticationServiceProtocol

    init(
        service: AuthenticationServiceProtocol =
            AuthenticationService()
    ) {
        self.service = service
    }

    func registerUser(
        username: String,
        email: String,
        password: String,
        confirmPassword: String
    ) {
        let normalizedUsername =
            username.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let normalizedEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()

        guard
            !normalizedUsername.isEmpty,
            !normalizedEmail.isEmpty,
            !password.isEmpty,
            !confirmPassword.isEmpty
        else {
            showSnackbar(
                message: "Por favor, preencha todos os campos.",
                type: .info
            )
            return
        }

        guard password == confirmPassword else {
            showSnackbar(
                message: "As senhas não coincidem.",
                type: .error
            )
            return
        }

        guard
            normalizedEmail.contains("@"),
            normalizedEmail.contains(".")
        else {
            showSnackbar(
                message: "Por favor, insira um e-mail válido.",
                type: .error
            )
            return
        }

        guard password.count >= 6 else {
            showSnackbar(
                message: "A senha deve ter no mínimo 6 caracteres.",
                type: .error
            )
            return
        }

        task?.cancel()

        viewState = .loading
        registeredEmail = nil

        task = Task {
            do {
                let response =
                    try await service.createRegister(
                        requestBody: .init(
                            username: normalizedUsername,
                            email: normalizedEmail,
                            password: password
                        )
                    )

                registeredEmail = response.email

                viewState = .loaded

                showSnackbar(
                    message: response.message,
                    type: .success
                )

            } catch is CancellationError {
                return

            } catch {
                viewState = .error

                let message =
                    error.localizedDescription

                showSnackbar(
                    message: message,
                    type: .error
                )
            }
        }
    }

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
