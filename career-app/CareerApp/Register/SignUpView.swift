//
//  SignUpView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @StateObject var viewModel:
        SignUpViewModel

    var goToLogin: () -> Void
    var onVerificationRequired: (
        _ email: String,
        _ username: String,
        _ password: String
    ) -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch viewModel.viewState {
                case .idle, .loaded, .error:
                    buildSignUpView()

                case .loading:
                    LoadingView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(
                    placement:
                        .navigationBarLeading
                ) {
                    Button(
                        action: goToLogin
                    ) {
                        Image(
                            systemName:
                                "chevron.left"
                        )
                        .font(
                            .system(
                                size: 18,
                                weight: .medium
                            )
                        )
                        .foregroundColor(
                            .persianBlue
                        )
                    }
                }
            }
            .padding()

            if viewModel.showSnackbar {
                SnackbarView(
                    message:
                        viewModel.snackbarMessage,
                    type:
                        viewModel.snackbarType
                )
                .padding(.bottom, 20)
            }
        }
        .animation(
            .easeInOut,
            value: viewModel.showSnackbar
        )
        .onChange(
            of: viewModel.registeredEmail
        ) { _, registeredEmail in
            guard let registeredEmail,
                  !registeredEmail.isEmpty
            else {
                return
            }

            onVerificationRequired(
                registeredEmail,
                username,
                password
            )
        }
    }

    @ViewBuilder
    private func buildSignUpView()
        -> some View {

        VStack(spacing: 20) {
            Text("Criar uma conta")
                .font(.largeTitle)
                .bold()
                .foregroundColor(
                    .adaptiveBlack
                )

            AuthTextField(
                icon: "person",
                placeholder: "Username",
                text: $username
            )

            AuthTextField(
                icon: "envelope",
                placeholder: "Email",
                text: $email
            )

            AuthTextField(
                icon: "lock",
                placeholder: "Senha",
                text: $password,
                isSecure: true
            )

            AuthTextField(
                icon: "lock",
                placeholder:
                    "Confirme a senha",
                text: $confirmPassword,
                isSecure: true
            )

            Text(
                """
                Ao clicar no botão Registrar, você concorda com a oferta pública.
                """
            )
            .font(.caption)
            .multilineTextAlignment(.center)

            PrimaryButton(
                title: "Criar Conta"
            ) {
                viewModel.registerUser(
                    username: username,
                    email: email,
                    password: password,
                    confirmPassword:
                        confirmPassword
                )
            }

            Divider()
                .padding(.vertical)

            HStack {
                Text("Já tem uma conta?")
                    .foregroundColor(
                        .adaptiveBlack
                    )
                    .font(
                        .system(size: 14)
                    )

                Button(
                    "Login",
                    action: goToLogin
                )
                .foregroundColor(
                    .persianBlue
                )
                .bold()
                .font(
                    .system(size: 14)
                )
            }
        }
    }
}
