//
//  SignUpViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

final class SignUpViewModel: ObservableObject {
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
    let service: AuthenticationServiceProtocol
    
    init(service: AuthenticationServiceProtocol = AuthenticationService()) {
        self.service = service
    }
    
    // MARK: - Business Logic
    @MainActor
    func registerUser(username: String, email: String, password: String, confirmPassword: String) {
        // 1. Validação de campos vazios
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            showSnackbar(message: "Por favor, preencha todos os campos.", type: .info)
            return // Interrompe a execução se houver campos vazios
        }
        
        // 2. Validação de senhas coincidentes
        guard password == confirmPassword else {
            showSnackbar(message: "As senhas não coincidem.", type: .error)
            return // Interrompe a execução se as senhas não coincidirem
        }
        
        // 3. Validação de formato de email (exemplo simples)
        // Você pode usar uma regex mais robusta ou uma biblioteca para isso
        guard email.contains("@") && email.contains(".") else {
            showSnackbar(message: "Por favor, insira um email válido.", type: .error)
            return
        }
        
        // 4. Validação de complexidade da senha (exemplo simples)
        guard password.count >= 6 else {
            showSnackbar(message: "A senha deve ter no mínimo 6 caracteres.", type: .error)
            return
        }
        
        self.viewState = .loading
        task = Task {
            do {
                try await service.createRegister(requestBody: .init(username: username, email: email, password: password))
                self.viewState = .loaded
                showSnackbar(message: "Cadastro realizado com sucesso!", type: .success)
                // Opcional: Chamar um callback ou navegar após o sucesso
                // self.onRegisterSuccess?()
            } catch {
                self.viewState = .error
                // Tenta extrair uma mensagem de erro mais amigável, se possível
                let errorMessage = (error as? LocalizedError)?.errorDescription ?? "Ocorreu um erro no cadastro. Tente novamente."
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
        
        // Esconde a snackbar automaticamente após alguns segundos
        Task {
            try await Task.sleep(for: .seconds(3)) // Tempo de exibição da snackbar
            // Garante que a snackbar só seja escondida se for a mesma mensagem
            // para evitar esconder uma nova mensagem que apareceu rapidamente
            if self.snackbarMessage == message {
                self.showSnackbar = false
            }
        }
    }
}
