//
//  SignUpView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Use @StateObject para instanciar ou observar seu ViewModel
    @StateObject var viewModel: SignUpViewModel
    
    var goToLogin: () -> Void
    var onRegister: () -> Void // Este callback pode ser disparado pelo ViewModel agora

    var body: some View {
        ZStack(alignment: .bottom) { // ZStack para a snackbar
            Group {
                // Conteúdo principal da tela de cadastro
                switch viewModel.viewState {
                case .idle, .loaded, .error:
                    buildsignUpView()
                case .loading:
                    LoadingView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        goToLogin()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.persianBlue)
                    }
                }
            }
            .padding()

            // --- A Snackbar ---
            if viewModel.showSnackbar {
                SnackbarView(message: viewModel.snackbarMessage, type: viewModel.snackbarType)
                    .padding(.bottom, 20) // Ajuste a posição
            }
        }
        .animation(.easeInOut, value: viewModel.showSnackbar) // Animação para a snackbar
    }
    
    @ViewBuilder
    private func buildsignUpView() -> some View {
        VStack(spacing: 20) {
            Text("Criar uma conta")
                .font(.largeTitle).bold()
                .foregroundColor(.adaptiveBlack)

            AuthTextField(icon: "person", placeholder: "Username", text: $username)
            AuthTextField(icon: "envelope", placeholder: "Email", text: $email) // Ícone de envelope para email
            AuthTextField(icon: "lock", placeholder: "Senha", text: $password, isSecure: true)
            AuthTextField(icon: "lock", placeholder: "Confirme a senha", text: $confirmPassword, isSecure: true)

            Text("Ao clicar no botão Registrar, você concorda com a oferta pública.")
                .font(.caption)
                .multilineTextAlignment(.center) // Para melhor leitura em várias linhas

            PrimaryButton(title: "Criar Conta", action: {
                // A View apenas passa os dados para o ViewModel
                viewModel.registerUser(username: username, email: email, password: password, confirmPassword: confirmPassword)
            })

            Divider()
                .padding(.vertical)

            HStack {
                Text("Já tem uma conta?")
                    .foregroundColor(.adaptiveBlack)
                    .font(.system(size: 14))
                Button("Login", action: goToLogin)
                    .foregroundColor(.persianBlue)
                    .bold()
                    .font(.system(size: 14))
            }
        }
    }
}
