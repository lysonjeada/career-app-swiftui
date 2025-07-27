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
                
                InterviewAssistantView(viewModel: GenerateQuestionsViewModel(),
                                       resumeFeedbackViewModel: ResumeFeedbackViewModel())
                    .tabItem {
                        Label(HomeStrings.interviewTitle, systemImage: "mic.fill")
                    }
                    .tag(TabSelection.interview)

                JobApplicationTrackerView(listViewModel: listViewModel, coordinator: coordinator)
                    .tabItem {
                        Label(HomeStrings.resumeTitle, systemImage: "book.fill")
                    }
                    .tag(TabSelection.tracker)

                MenuView(coordinator: coordinator)
                    .tabItem {
                        Label(HomeStrings.menuTitle, systemImage: "line.horizontal.3")
                    }
                    .tag(TabSelection.menu)
            }
            .tint(.persianBlue) // Cor dos itens selecionados do tab bar
            .onAppear {
                // Configuração da aparência do tab bar para iOS 15+
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.persianBlue)
                
                // Cor dos itens não selecionados
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
                
                // Cor dos itens selecionados
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                print("ContentView loaded with userId: \(userId ?? "nil")")
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(navigationTitle)
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.push(page: .profile(userId: userId))
                    }) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                    }
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
