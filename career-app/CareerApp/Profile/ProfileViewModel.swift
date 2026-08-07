//
//  ProfileViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import SwiftUI
import Combine 

@MainActor
final class ProfileViewModel:
    ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error
    }

    @Published private(set)
    var viewState: State = .idle

    @Published var username = ""
    @Published var email = ""

    @Published var loggedInUser:
        AuthenticationLoginResponse?

    @Published private(set)
    var isDeletingUser = false

    @Published private(set)
    var didDeleteUser = false

    @Published private(set)
    var deletionErrorMessage: String?

    private var profileTask:
        Task<Void, Never>?

    private var deletionTask:
        Task<Void, Never>?

    private let service:
        ProfileServiceProtocol

    init(
        service: ProfileServiceProtocol =
            ProfileService()
    ) {
        self.service = service
    }

    func fetchProfile(
        userId: String
    ) {
        profileTask?.cancel()

        viewState = .loading

        profileTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let user =
                    try await service.fetchProfile(
                        userId: userId
                    )

                guard !Task.isCancelled else {
                    return
                }

                loggedInUser = user
                username = user.username
                email = user.email
                viewState = .loaded

            } catch is CancellationError {
                return

            } catch {
                viewState = .error

                print(
                    "❌ Erro ao carregar perfil:",
                    error.localizedDescription
                )
            }
        }
    }

    func deleteUser(
        userId: String
    ) {
        let normalizedUserId =
            userId.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedUserId.isEmpty else {
            deletionErrorMessage =
                "Não foi possível identificar o usuário."
            return
        }

        deletionTask?.cancel()

        isDeletingUser = true
        didDeleteUser = false
        deletionErrorMessage = nil

        deletionTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                try await service.deleteUser(
                    userId: normalizedUserId
                )

                guard !Task.isCancelled else {
                    return
                }

                isDeletingUser = false
                didDeleteUser = true

            } catch is CancellationError {
                isDeletingUser = false

            } catch {
                isDeletingUser = false
                deletionErrorMessage =
                    error.localizedDescription

                print(
                    "❌ Erro ao excluir usuário:",
                    error.localizedDescription
                )
            }
        }
    }

    func consumeDeletionSuccess() {
        didDeleteUser = false
    }

    func clearDeletionError() {
        deletionErrorMessage = nil
    }

    deinit {
        profileTask?.cancel()
        deletionTask?.cancel()
    }
}
