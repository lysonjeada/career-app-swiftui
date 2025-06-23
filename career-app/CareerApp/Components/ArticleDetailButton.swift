//
//  ArticleDetailButton.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 29/03/25.
//

import SwiftUI

struct ArticleDetailButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text("IR ATÉ O ARTIGO")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                Spacer()
            }
            .padding(.vertical, 16)
            .background(Color.persianBlue)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            .shadow(color: .persianBlue.opacity(0.4), radius: 8, x: 0, y: 4)
        )}
    }
}
