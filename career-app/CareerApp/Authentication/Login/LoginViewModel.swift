//
//  LoginViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import SwiftUI
import Combine // Para @Published

final class LoginViewModel: ObservableObject {
    // MARK: - View State
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error
    }
    
    @Published private(set) var viewState: State = .idle
    
    @Published var showSnackbar: Bool = false
    @Published var snackbarMessage: String = ""
    @Published var snackbarType: SnackbarType = .info
    
    // MARK: - Dependencies
    private var task: Task <Void, Never>?
    let service: AuthenticationServiceProtocol // Usando o protocolo mais genérico
    
    // Propriedade para armazenar o usuário logado, se necessário
    @Published var loggedInUser: AuthenticationLoginResponse?
    
    init(service: AuthenticationServiceProtocol = AuthenticationService()) {
        self.service = service
    }
    
    // MARK: - Business Logic
    @MainActor
    func performLogin(username: String, password: String) {
        // 1. Validação de campos vazios
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            showSnackbar(message: "Por favor, preencha todos os campos.", type: .info)
            return
        }
        
        self.viewState = .loading
        task = Task {
            do {
                let user = try await service.fetchLogin(requestBody: .init(username: username, password: password))
                self.loggedInUser = user // Armazena o usuário logado
                self.viewState = .loaded
                showSnackbar(message: "Login bem-sucedido!", type: .success)
            } catch {
                self.viewState = .error
                let errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro no login. Tente novamente."
                showSnackbar(message: errorMessage, type: .error)
            }
        }
    }
    
    // MARK: - Snackbar Helper
    @MainActor
    private func showSnackbar(message: String, type: SnackbarType) {
        self.snackbarMessage = message
        self.snackbarType = type
        self.showSnackbar = true
        
        Task {
            try await Task.sleep(for: .seconds(3))
            if self.snackbarMessage == message {
                self.showSnackbar = false
            }
        }
    }
}
