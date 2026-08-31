//
//  ContentView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 12/08/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @StateObject var viewModel: HomeViewModel
    @StateObject var listViewModel: JobApplicationTrackerListViewModel
    let userId: String?
    
    private var navigationTitle: String {
        return deepLinkManager.title
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $deepLinkManager.selectedTab) {
                HomeView(viewModel: viewModel, output: .init(goToMainScreen: { }, goToForgotPassword: { }))
                    .tabItem {
                        Label(HomeStrings.homeTitle, systemImage: "doc.text")
                    }
                    .tag(TabSelection.home)
                
                InterviewAssistantView(interviewAssistant: coordinator.interviewAssistant,
                                       viewModel: GenerateQuestionsViewModel(),
                                       resumeFeedbackViewModel: ResumeFeedbackViewModel())
                    .tabItem {
                        Label(HomeStrings.interviewTitle, systemImage: "mic.fill")
                    }
                    .tag(TabSelection.interview)

                JobApplicationTrackerView(listViewModel: listViewModel, coordinator: coordinator.track)
                    .tabItem {
                        Label(HomeStrings.resumeTitle, systemImage: "book.fill")
                    }
                    .tag(TabSelection.tracker)
                
                TutorsView()
                    .tabItem {
                        // A tab bar flutuante (iOS 18+) ignora tanto
                        // .badge() customizado (sempre vira bolha
                        // vermelha do sistema) quanto cor customizada
                        // no Label (testei os dois — sem efeito
                        // nenhum, o próprio SO decide a cor pelo
                        // estado selecionado/não selecionado). O
                        // único jeito confiável de comunicar "em
                        // breve" aqui é o próprio texto do item.
                        Label("Em breve", systemImage: "person.2")
                    }
                    .tag(TabSelection.tutors)

                MenuView(coordinator: coordinator)
                    .tabItem {
                        Label(HomeStrings.menuTitle, systemImage: "line.horizontal.3")
                    }
                    .tag(TabSelection.menu)
            }
            .onAppear {
                // O reset da aba para Home num login novo fica em
                // Coordinator.isLoggedIn.didSet (amarrado à transição
                // de estado) — aqui dispararia de novo a cada
                // push/pop que volta pra raiz, travando "voltar" em
                // qualquer tela na aba Home.

                // Configuração da aparência do tab bar para iOS 15+
                //
                // O fundo da tab bar é opaco e sempre persianBlue
                // (não é o material translúcido do "Liquid Glass" —
                // configureWithOpaqueBackground + backgroundColor
                // continuam sendo respeitados neste app). Por isso o
                // item selecionado precisa de uma cor explícita que
                // contraste com esse fundo: deixá-lo seguir
                // .tint(.persianBlue) fazia o ícone/texto selecionado
                // ficar exatamente da cor do fundo — item "sumindo"
                // sempre que a aba estava ativa. Branco no
                // selecionado e cinza do sistema no não selecionado
                // contrastam bem nos dois temas.
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.persianBlue)

                for layout in [
                    appearance.stackedLayoutAppearance,
                    appearance.inlineLayoutAppearance,
                    appearance.compactInlineLayoutAppearance
                ] {
                    layout.selected.iconColor = .white
                    layout.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
                }

                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance

                print("ContentView loaded with userId: \(userId ?? "nil")")
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        coordinator.profile.push(.profile(userId: userId))
                    }) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                    }
                    
                    .buttonStyle(.plain)
                }
            }
            .toolbarBackground(Color.persianBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .accentColor(.white) // Cor dos botões da navigation bar
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(), listViewModel: .init(), userId: nil)
    }
}
