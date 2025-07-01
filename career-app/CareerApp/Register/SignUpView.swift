//
//  SignUpView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    var goToLogin: () -> Void
    var onRegister: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Create an account")
                .font(.largeTitle).bold()
                .foregroundColor(.adaptiveBlack)

            AuthTextField(icon: "person", placeholder: "Username or Email", text: $email)
            AuthTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
            AuthTextField(icon: "lock", placeholder: "ConfirmPassword", text: $confirmPassword, isSecure: true)

            Text("By clicking the Register button, you agree to the public offer")
                .font(.caption)

            PrimaryButton(title: "Create Account", action: onRegister)

            Divider()
                .padding(.vertical)

            HStack {
                Button("I Already Have an Account", action: goToLogin)
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                Button("Login", action: goToLogin)
                    .foregroundColor(.persianBlue)
                    .bold()
                    .font(.system(size: 14))
            }
            
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
