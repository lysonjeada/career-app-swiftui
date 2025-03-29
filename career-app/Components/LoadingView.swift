//
//  LoadingView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 29/03/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Fundo Persian Blue sólido
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            // Container centralizado
            VStack(spacing: 16) {
                // Spinner minimalista
                MinimalSpinner()
                    .frame(width: 60, height: 60)
            }
        }
    }
}

struct MinimalSpinner: View {
    @State private var rotationAngle: Double = 0
    private let lineWidth: CGFloat = 4
    
    var body: some View {
        ZStack {
            // Círculo de fundo (sutil)
            Circle()
                .stroke(Color.persianBlue.opacity(0.1), lineWidth: lineWidth)
            
            // Arco animado
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    Color.persianBlue,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360
                    }
                }
        }
        .frame(width: 50, height: 50)
    }
    
    // Visualização prévia
    struct LoadingView_Previews: PreviewProvider {
        static var previews: some View {
            LoadingView()
        }
    }
}
