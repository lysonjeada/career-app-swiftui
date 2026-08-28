//
//  ResetPasswordView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/08/26.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var didSucceed = false

    @ObservedObject var viewModel: PasswordResetViewModel

    var goToLogin: () -> Void

    var body: some View {
        Group {
            if didSucceed {
                successContent
            } else {
                formContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            if !didSucceed {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: goToLogin) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.persianBlue)
                    }
                }
            }
        }
        .padding()
    }

    private var formContent: some View {
        VStack(spacing: 20) {
            Text("Nova senha")
                .font(.largeTitle).bold()
                .foregroundColor(.adaptiveBlack)

            Text(
                "Crie uma nova senha para a sua conta. "
                + "Todas as sessões anteriores serão encerradas."
            )
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)

            AuthTextField(
                icon: "lock",
                placeholder: "Nova senha",
                text: $newPassword,
                isSecure: true
            )

            AuthTextField(
                icon: "lock",
                placeholder: "Confirmar nova senha",
                text: $confirmPassword,
                isSecure: true
            )

            if let error = viewModel.resetPasswordErrorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            submitButton
        }
    }

    private var submitButton: some View {
        Button {
            Task {
                let succeeded = await viewModel.resetPassword(
                    newPassword: newPassword,
                    confirmPassword: confirmPassword
                )

                if succeeded {
                    withAnimation {
                        didSucceed = true
                    }
                }
            }
        } label: {
            HStack {
                if viewModel.isResettingPassword {
                    ProgressView()
                        .tint(.white)
                }

                Text("Redefinir senha")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.persianBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(viewModel.isResettingPassword)
    }

    private var successContent: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)

            Text("Senha redefinida com sucesso.")
                .font(.title2).bold()
                .foregroundColor(.adaptiveBlack)
                .multilineTextAlignment(.center)

            Text("Faça login novamente com sua nova senha.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Spacer()

            PrimaryButton(
                title: "Voltar para o login",
                action: goToLogin
            )
        }
    }
}

#Preview {
    NavigationView {
        ResetPasswordView(
            viewModel: PasswordResetViewModel(),
            goToLogin: {}
        )
    }
}
