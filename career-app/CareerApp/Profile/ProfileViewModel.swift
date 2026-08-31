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

    @Published var loggedInUser: AuthenticationUserResponse?

    @Published private(set)
    var isDeletingUser = false

    @Published private(set)
    var didDeleteUser = false

    @Published private(set)
    var deletionErrorMessage: String?

    // MARK: - Perfil local (Core Data)

    @Published var name = ""
    @Published var experience = ""
    @Published var institution = ""
    @Published var githubLink = ""
    @Published var portfolioLink = ""

    @Published private(set) var profileImageData: Data?

    @Published private(set) var isSavingLocalProfile = false
    @Published private(set) var localProfileErrorMessage: String?

    private var profileTask:
        Task<Void, Never>?

    private var deletionTask:
        Task<Void, Never>?

    private let service:
        ProfileServiceProtocol

    private let localProfileService:
        LocalProfileServiceProtocol

    init(
        service: ProfileServiceProtocol =
            ProfileService(),
        localProfileService: LocalProfileServiceProtocol =
            LocalProfileService()
    ) {
        self.service = service
        self.localProfileService = localProfileService
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

    func loadLocalProfile() {
        guard let data = localProfileService.loadProfile() else {
            return
        }

        name = data.name
        experience = data.experience
        institution = data.institution
        githubLink = data.githubLink
        portfolioLink = data.portfolioLink
        profileImageData = data.imageData
    }

    func saveLocalProfile(imageData: Data?) {
        isSavingLocalProfile = true

        let data = LocalProfileData(
            name: name,
            experience: experience,
            institution: institution,
            githubLink: githubLink,
            portfolioLink: portfolioLink,
            imageData: imageData
        )

        do {
            try localProfileService.saveProfile(data)
            profileImageData = imageData

        } catch {
            print("Erro ao salvar: \(error)")
        }

        isSavingLocalProfile = false
    }

    func deleteProfileImage() {
        profileImageData = nil

        do {
            try localProfileService.deleteProfileImage()
            print("Imagem removida com sucesso")

        } catch {
            print(
                "Erro ao remover imagem: \(error.localizedDescription)"
            )

            localProfileErrorMessage = "Erro ao remover imagem"
        }
    }

    func deleteLocalProfile() {
        do {
            try localProfileService.deleteProfile()

            profileImageData = nil
            name = ""
            experience = ""
            institution = ""
            githubLink = ""
            portfolioLink = ""

        } catch {
            /*
             A conta já foi excluída no servidor.
             Um erro local não deve manter o usuário logado.
             */
            print(
                "❌ Erro ao limpar perfil local:",
                error.localizedDescription
            )
        }
    }

    func clearLocalProfileError() {
        localProfileErrorMessage = nil
    }

    deinit {
        profileTask?.cancel()
        deletionTask?.cancel()
    }
}
