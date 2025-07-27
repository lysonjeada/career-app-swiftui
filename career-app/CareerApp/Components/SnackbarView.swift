//
//  SnackbarView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import SwiftUI

struct SnackbarView: View {
    let message: String
    let type: SnackbarType // Use o enum SnackbarType do ViewModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: type.iconName)
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white)
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(type.backgroundColor)
        .cornerRadius(8)
        .shadow(radius: 5)
        .transition(.move(edge: .bottom).combined(with: .opacity)) // Animação de entrada/saída
        .zIndex(1) // Garante que a snackbar fique acima de outros conteúdos
    }
}

enum SnackbarType {
        case success
        case error
        case info
        
        var backgroundColor: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
