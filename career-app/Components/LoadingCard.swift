//
//  LoadingCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct LoadingCard: View {
    let style: CardStyle
    let title: String?
    
    // Animation state
    @State private var isAnimating = false
    
    enum CardStyle {
        case article
        case job
        case carousel
    }
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.titleSectionColor)
                    .shimmering(active: isAnimating)
            }
            
            switch style {
            case .article:
                buildArticle()
            case .job:
                buildJob()
            case .carousel:
                buildCarousel()
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - View Builders with Animation
    
    @ViewBuilder
    private func buildJob() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0...2, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.skeletonColor)
                            .frame(height: 20)
                            .shimmering(active: isAnimating)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.skeletonColor)
                            .frame(height: 16)
                            .shimmering(active: isAnimating)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.skeletonColor)
                            .frame(width: 48, height: 16)
                            .shimmering(active: isAnimating)
                    }
                    .padding(.horizontal, 16)
                    .frame(width: 160, height: 120)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    @ViewBuilder
    private func buildArticle() -> some View {
        ScrollView {
            HStack(spacing: 16) {
                ForEach(1...2, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.skeletonColor)
                                .frame(width: 80, height: 80)
                                .shimmering(active: isAnimating)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.skeletonColor)
                                .frame(height: 40)
                                .shimmering(active: isAnimating)
                        }
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.skeletonColor)
                            .frame(height: 32)
                            .shimmering(active: isAnimating)
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.skeletonColor)
                                .frame(width: 40, height: 14, alignment: .leading)
                                .shimmering(active: isAnimating)
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.skeletonColor)
                                .frame(width: 40, height: 14, alignment: .trailing)
                                .shimmering(active: isAnimating)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func buildCarousel() -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.skeletonColor)
                    .frame(height: 100)
                    .shimmering(active: isAnimating)
                    .padding(.bottom, 16)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.skeletonColor)
                    .frame(height: 40)
                    .shimmering(active: isAnimating)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
    }
}

// MARK: - Shimmer Effect Modifier

extension View {
    @ViewBuilder
    func shimmering(active: Bool) -> some View {
        if active {
            self.modifier(ShimmerEffect())
        } else {
            self
        }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.5),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

#Preview {
    VStack {
        LoadingCard(style: .job, title: "Próximas Entrevistas")
        Divider()
        LoadingCard(style: .article, title: "Artigos")
        Divider()
        LoadingCard(style: .carousel, title: nil)
    }
    
}
