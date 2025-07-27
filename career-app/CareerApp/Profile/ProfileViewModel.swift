//
//  ProfileViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import SwiftUI
import Combine // Para @Published

final class ProfileViewModel: ObservableObject {
    // MARK: - View State
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error
    }
    
    @Published private(set) var viewState: State = .idle
    
    @Published var username: String = ""
    @Published var email: String = ""
    
    // MARK: - Dependencies
    private var task: Task <Void, Never>?
    let service: ProfileServiceProtocol // Usando o protocolo mais genérico
    
    // Propriedade para armazenar o usuário logado, se necessário
    @Published var loggedInUser: AuthenticationLoginResponse?
    
    init(service: ProfileServiceProtocol = ProfileService()) {
        self.service = service
    }
    
    // MARK: - Business Logic
    @MainActor
    func fetchProfile(userId: String) {
        self.viewState = .loading
        task = Task {
            do {
                let user = try await service.fetchProfile(userId: userId)
                self.loggedInUser = user // Armazena o usuário logado
                self.username = user.username
                self.email = user.email
                self.viewState = .loaded
            } catch {
                self.viewState = .error
                let errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro no login. Tente novamente."
            }
        }
    }
}
