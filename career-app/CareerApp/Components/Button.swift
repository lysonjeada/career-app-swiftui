//
//  Button.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.persianBlue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

struct SecondaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .foregroundColor(.persianBlue)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.persianBlue, lineWidth: 2)
                )
        }
    }
}

struct PrimaryButtonWithIcon: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: title)
                .frame(width: 64, height: 64)
                .background(Color.persianBlue)
                .foregroundColor(.white)
                .cornerRadius(32)
        }
        .shadow(radius: 2)
    }
}

struct SecondaryButtonWithIcon: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: title)
                .frame(width: 64, height: 64)
                .background(Color.white)
                .foregroundColor(.persianBlue)
                .cornerRadius(32)
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.persianBlue, lineWidth: 2)
                )
        }
        .shadow(radius: 2)
    }
}
