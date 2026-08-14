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
        NavigationStack(path: $coordinator.path) { // Garanta que o NavigationStack usa o path do coordinator
            VStack {
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Menu")
                        .bold()
                        .font(.system(size: 28))
                        .foregroundColor(.persianBlue)
                }
            }
        }
    }
}

// Preview da MenuView
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(coordinator: Coordinator())
            .environmentObject(Coordinator()) // Fornecer um EnvironmentObject para o Preview
    }
}
