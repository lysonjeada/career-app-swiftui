//
//  LoginView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 15/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = "" // Renomeei de 'name' para 'username' para consistência
    @State private var password: String = ""
    
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: LoginViewModel // Adicionado StateObject para o ViewModel
    
    // Callback para quando o login for bem-sucedido
    var onLoginSuccess: (_ userId: String) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) { // ZStack para a snackbar
            Group {
                switch viewModel.viewState {
                case .idle, .loaded, .error:
                    buildLoginContentView()
                case .loading:
                    LoadingView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.persianBlue, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TechStep")
                        .bold()
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            // Reage ao estado de 'loaded' no ViewModel para chamar onLoginSuccess
            .onChange(of: viewModel.viewState) {
                if viewModel.viewState == .loaded {
                    if let userId = viewModel.loggedInUser?.id.uuidString {
                        onLoginSuccess(userId)
                    }

                }
            }
            
            // --- A Snackbar ---
            if viewModel.showSnackbar {
                SnackbarView(message: viewModel.snackbarMessage, type: viewModel.snackbarType)
                    .padding(.bottom, 20) // Ajuste a posição
            }
        }
        .animation(.easeInOut, value: viewModel.showSnackbar) // Animação para a snackbar
    }
    
    @ViewBuilder
    private func buildLoginContentView() -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.persianBlue)
                
                Text("Faça o login para continuar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("EMAIL/USERNAME") // Pode ser email ou username, dependendo do backend
                        .font(.caption)
                        .foregroundColor(.gray)
                    // Usando AuthTextField para consistência com o SignUpView
                    AuthTextField(icon: "person", placeholder: "Seu email ou username", text: $username, isSecure: false)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("SENHA")
                        .font(.caption)
                        .foregroundColor(.gray)
                    // Usando AuthTextField para consistência, com opção de visibilidade
                    AuthTextField(icon: "lock", placeholder: "Sua senha", text: $password, isSecure: true)
                }
            }
            
            Button(action: {
                // Chama a função de login no ViewModel
                viewModel.performLogin(username: username, password: password)
            }) {
                Text("Log in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.persianBlue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
            
            Button(action: {
                coordinator.isLoggedIn = true // Entrar sem login
                coordinator.popToRoot()
            }) {
                Text("Entrar sem login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.persianBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.persianBlue, lineWidth: 2)
                    )
            }
            
            HStack {
                Button("Esqueceu a senha?") {
                    coordinator.push(page: .forgotPassword)
                }
                .foregroundColor(.persianBlue)
                Spacer()
                Button("Cadastre-se") {
                    coordinator.push(page: .signUp)
                }
                .foregroundColor(.persianBlue)
            }
            .font(.footnote)
            .padding(.top, 20)
            
            Spacer()
        }
    }
}

// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(), onLoginSuccess: { userId in })
    }
}
