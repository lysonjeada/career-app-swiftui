//
//  MenuView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/03/25.
//

import SwiftUI

import SwiftUI

struct MenuView: View {
    @StateObject var coordinator: Coordinator // Deve ser @EnvironmentObject se for o mesmo coordinator do App
    
    // Se o coordinator for o EnvironmentObject do seu App, use assim:
    // @EnvironmentObject var coordinator: Coordinator
    
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

// Exemplo de RootView no seu App
/*
 @main
 struct MyApp: App {
     @StateObject var coordinator = Coordinator()

     var body: some Scene {
         WindowGroup {
             // A RootView que decide qual tela mostrar
             if coordinator.isLoggedIn {
                 MainAppView() // Ou uma TabView, etc.
                     .environmentObject(coordinator)
             } else {
                 LoginView(viewModel: LoginViewModel(), onLoginSuccess: {
                     coordinator.isLoggedIn = true // Define como logado após sucesso
                 })
                     .environmentObject(coordinator)
             }
         }
     }
 }
 */

// Preview da MenuView
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(coordinator: Coordinator())
            .environmentObject(Coordinator()) // Fornecer um EnvironmentObject para o Preview
    }
}
