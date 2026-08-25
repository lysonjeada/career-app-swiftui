//
//  MenuView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/03/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject var coordinator: Coordinator

    var body: some View {
        List {
            Button {
                coordinator.push(page: .profile(userId: coordinator.currentUserId))
            } label: {
                HStack {
                    Text("Perfil")
                        .foregroundColor(.persianBlue)
                        .font(.system(size: 20))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.persianBlue)
                }
            }
            .listRowBackground(Color.backgroundLightGray)

            Button {
                coordinator.push(
                    page: .videos
                )

            } label: {
                HStack {
                    Text("Vídeos")
                        .foregroundColor(
                            .persianBlue
                        )
                        .font(
                            .system(size: 20)
                        )

                    Spacer()

                    Image(
                        systemName: "video"
                    )
                    .foregroundColor(
                        .persianBlue
                    )
                }
            }
            .listRowBackground(
                Color.backgroundLightGray
            )

            Button {
                coordinator.push(
                    page: .aiCredits
                )

            } label: {
                HStack {
                    Text("Créditos de IA")
                        .foregroundColor(
                            .persianBlue
                        )
                        .font(
                            .system(size: 20)
                        )

                    Spacer()

                    Image(
                        systemName: "sparkles"
                    )
                    .foregroundColor(
                        .persianBlue
                    )
                }
            }
            .listRowBackground(
                Color.backgroundLightGray
            )

            // --- BOTÃO DE SAIR DA CONTA ---
            Button {
                coordinator.performLogout() // Chama o novo método de logout
            } label: {
                HStack {
                    Text("Sair da conta")
                        .foregroundColor(.red) // Destaque a cor para indicar uma ação de logout
                        .font(.system(size: 20))
                    Spacer()
                    Image(systemName: "rectangle.portrait.and.arrow.right") // Ícone de "sair"
                        .foregroundColor(.red)
                }
            }
            .listRowBackground(Color.backgroundLightGray)
        }
        .background(Color.backgroundLightGray) // Aplica o fundo à List, se necessário
        // O título "Menu" já é exibido pelo toolbar do ContentView
        // (via deepLinkManager.title), então não é repetido aqui.
    }
}

// Preview da MenuView
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MenuView(coordinator: Coordinator())
        }
        .environmentObject(Coordinator()) // Fornecer um EnvironmentObject para o Preview
    }
}
