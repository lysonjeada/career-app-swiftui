//
//  TutorsView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import SwiftUI

struct TutorsView: View {
    @State private var isWiggling = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            comingSoonContent

            comingSoonBadge
                .padding(.top, 8)
                .padding(.trailing, 16)
        }
        .navigationTitle("Tutores")
    }

    private var comingSoonBadge: some View {
        Text("Em breve")
            .font(.caption.weight(.bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.orange)
            )
    }

    private var comingSoonContent: some View {
        VStack(spacing: 24) {
            Spacer()

            constructionIllustration

            VStack(spacing: 8) {
                Text("Página em construção")
                    .font(.title2.bold())
                    .foregroundColor(.persianBlue)

                Text(
                    """
                    Estamos preparando um espaço para você \
                    conhecer tutores, agendar mentorias e \
                    conversar direto com eles por aqui.
                    """
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var constructionIllustration: some View {
        ZStack {
            ConstructionStripes()
                .frame(width: 220, height: 220)
                .clipShape(Circle())
                .opacity(0.15)

            Circle()
                .fill(Color.persianBlue.opacity(0.08))
                .frame(width: 180, height: 180)

            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundColor(.persianBlue.opacity(0.35))
                .offset(y: 6)

            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(14)
                .background(Circle().fill(Color.orange))
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .rotationEffect(.degrees(isWiggling ? -12 : 12))
                .offset(x: 50, y: 50)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isWiggling
                )
        }
        .onAppear {
            isWiggling = true
        }
    }
}

/// Faixa diagonal estilo "fita de obra em construção", usada só como
/// textura decorativa atrás do ícone — puramente visual, sem estado.
private struct ConstructionStripes: View {
    private let stripeWidth: CGFloat = 14

    var body: some View {
        GeometryReader { geometry in
            let stripeCount = Int(geometry.size.width / stripeWidth) + 6

            HStack(spacing: stripeWidth) {
                ForEach(0..<stripeCount, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: stripeWidth)
                }
            }
            .frame(
                width: geometry.size.width * 2,
                height: geometry.size.height * 2
            )
            .rotationEffect(.degrees(45))
            .offset(
                x: -geometry.size.width / 2,
                y: -geometry.size.height / 2
            )
        }
    }
}

#Preview {
    NavigationView {
        TutorsView()
    }
}
