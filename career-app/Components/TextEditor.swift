//
//  TextEditor.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 03/01/25.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var text: String
    @State private var isExpanded: Bool = false
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isFocused: Bool
    
    var body: some View {
            VStack {
                TextEditor(text: $text)
                    
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.backgroundLightGray)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.persianBlueWithoutOpacity, lineWidth: 1)
                    )
                    .focused($isFocused)
                    .onChange(of: isFocused) { newValue in
                        withAnimation(.easeInOut) {
                            isExpanded = newValue
                        }
                    }
                if isExpanded {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isExpanded = false
                            isFocused = false
                        }
                    }) {
                        Text("Concluir")
                            .font(.footnote)
                            .padding(.top, 8)
                            .foregroundColor(.persianBlueWithoutOpacity)
                    }
                }
                
            }
           
            .padding(.top, isExpanded ? 8 : 12)
            .padding(.horizontal, isExpanded ? 12 : 72)
    }
}
