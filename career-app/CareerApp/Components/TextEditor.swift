//
//  TextEditor.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 03/01/25.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var text: String
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isFocused: Bool
    var action: () -> Void

    var body: some View {
        VStack {
            TextEditor(text: $text)
                .frame(height: 100) // Altura fixa (equivalente à expandida)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.backgroundLightGray)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.persianBlueWithoutOpacity, lineWidth: 1)
                )
                .focused($isFocused)
            
            Button(action: {
                isFocused = false
                action()
            }) {
                Text("Concluir")
                    .font(.footnote)
                    .padding(.top, 8)
                    .foregroundColor(.persianBlueWithoutOpacity)
            }
        }
    }
}
