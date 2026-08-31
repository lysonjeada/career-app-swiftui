//
//  InsufficientCreditsPromptView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import SwiftUI

/// Reaproveitado por todas as funcionalidades de IA (geração de
/// perguntas, simulação de entrevista, plano de estudos, feedback de
/// currículo) quando o backend responde `INSUFFICIENT_AI_CREDITS` —
/// evita duplicar essa tela e o fluxo de compra em cada uma delas.
///
/// O `.sheet` de compra é local (`showPurchaseSheet`), não passa pelo
/// Coordinator — exceção intencional: este componente é embutido em
/// várias telas hospedeiras diferentes, cada uma já dona da sua própria
/// navegação; fazer isso passar por uma rota do Coordinator obrigaria
/// cada tela hospedeira a saber sobre esse sheet específico.
struct InsufficientCreditsPromptView: View {
    @State private var showPurchaseSheet = false

    var body: some View {
        ContentUnavailableView {
            Label(
                "Créditos insuficientes",
                systemImage: "sparkles"
            )
        } description: {
            Text(
                "Você não possui créditos de IA suficientes para continuar."
            )
        } actions: {
            Button("Comprar créditos") {
                showPurchaseSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.persianBlue)
        }
        .sheet(isPresented: $showPurchaseSheet) {
            NavigationStack {
                AICreditsView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fechar") {
                                showPurchaseSheet = false
                            }
                        }
                    }
            }
        }
    }
}

#if DEBUG
#Preview {
    InsufficientCreditsPromptView()
}
#endif
