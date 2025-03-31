//
//  LoginView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 15/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var name: String = "yurialberto2000@gmail.com"
    @State private var password: String = ""
    @EnvironmentObject private var coordinator: Coordinator
    
    var body: some View {
        
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
                    Text("EMAIL")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("SENHA")
                        .font(.caption)
                        .foregroundColor(.gray)
                    SecureField("", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            Button(action: {
                // Login action
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
                coordinator.isLoggedIn = true
                coordinator.popToRoot()
//                coordinator.push(page: .main)
            }) {
                Text("Entrar sem login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.persianBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.persianBlue, lineWidth: 1)
                    )
            }
            HStack {
                Button("Esqueceu a senha?") {
                }
                .foregroundColor(.persianBlue)
                Spacer()
                Button("Cadastre-se") {
                    // Signup action
                }
                .foregroundColor(.persianBlue)
            }
            .font(.footnote)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 50)
    }
}

// Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
