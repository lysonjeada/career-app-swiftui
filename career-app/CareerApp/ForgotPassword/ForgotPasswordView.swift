//
//  ForgotPasswordView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    var goToLogin: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot password?")
                .font(.largeTitle).bold()
                .foregroundColor(.adaptiveBlack)

            AuthTextField(icon: "envelope", placeholder: "Enter your email address", text: $email)

            Text("* We will send you a message to set or reset your new password")
                .font(.caption)
                .foregroundColor(.gray)

            PrimaryButton(title: "Submit", action: goToLogin)
        }
        .navigationBarBackButtonHidden(true) // 1. Esconde o botão padrão
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
    }
}
