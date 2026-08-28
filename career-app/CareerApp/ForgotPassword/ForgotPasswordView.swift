//
//  ForgotPasswordView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""

    @ObservedObject var viewModel: PasswordResetViewModel

    var goToLogin: () -> Void
    var onCodeSent: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Esqueceu sua senha?")
                .font(.largeTitle).bold()
                .foregroundColor(.adaptiveBlack)

            AuthTextField(
                icon: "envelope",
                placeholder: "Digite seu endereço de e-mail",
                text: $email
            )
            .keyboardType(.emailAddress)

            Text(
                "* Enviaremos um código para o seu e-mail para que "
                + "você possa redefinir sua senha."
            )
            .font(.caption)
            .foregroundColor(.gray)

            if let error = viewModel.requestCodeErrorMessage {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            submitButton
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: goToLogin) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.persianBlue)
                }
            }
        }
        .onAppear {
            viewModel.reset()
        }
        .padding()
    }

    private var submitButton: some View {
        Button {
            Task {
                let succeeded = await viewModel.requestPasswordReset(
                    email: email
                )

                if succeeded {
                    onCodeSent()
                }
            }
        } label: {
            HStack {
                if viewModel.isRequestingCode {
                    ProgressView()
                        .tint(.white)
                }

                Text("Enviar código")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.persianBlue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(viewModel.isRequestingCode)
    }
}

#Preview {
    NavigationView {
        ForgotPasswordView(
            viewModel: PasswordResetViewModel(),
            goToLogin: {},
            onCodeSent: {}
        )
    }
}
