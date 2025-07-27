//
//  AuthTextField.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct AuthTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false // Indica se o campo DEVE ser um campo de senha

    @State private var isPasswordVisible: Bool = false // Controla a visibilidade atual da senha

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)

            // Se o campo for de senha, usa a lógica de alternância
            if isSecure {
                if isPasswordVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
                
                // Botão para alternar a visibilidade da senha
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            } else {
                // Se não for um campo de senha, é apenas um TextField normal
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
