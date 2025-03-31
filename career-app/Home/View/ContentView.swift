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
    @State private var searchText = ""
    
    private var navigationTitle: String {
        return deepLinkManager.title
    }
    
    private var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.circle")
                .resizable()
                .clipShape(Circle())
                .frame(width: 28, height: 28)
                .foregroundColor(Color.white)
        }
    }
    
    private var searchField: some View {
        HStack {
            ZStack(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                Spacer()
                
                TextField("Pesquisar", text: $searchText)
                    .padding(.leading, 40)
            }
            .padding(8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
        .frame(width: 200)
    }
    
    var body: some View {
        TabView(selection: $deepLinkManager.selectedTab) {
            
            HomeView(viewModel: viewModel, output: .init(goToMainScreen: { }, goToForgotPassword: { }))
            
                .tabItem {
                    Label(HomeStrings.homeTitle, systemImage: "doc.text")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.home)
                .toolbarBackground(Color.persianBlue, for:
                        .tabBar) // Fundo azul para a TabBar
                .toolbarColorScheme(.light, for: .tabBar) // Garante ícones claros
                .tint(.white)
            
            
            InterviewGenerateQuestionsView(viewModel: GenerateQuestionsViewModel())
                .tabItem {
                    Label(HomeStrings.interviewTitle, systemImage: "mic.fill")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.interview)
                .toolbarBackground(.visible, for: .tabBar)
            
            
            JobApplicationTrackerView()
            
                .tabItem {
                    Label(HomeStrings.resumeTitle, systemImage: "book.fill")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.tracker)
            
            
            MenuView()
            
                .tabItem {
                    Label(HomeStrings.menuTitle, systemImage: "line.horizontal.3")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.menu)
                
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                searchField
            }
            ToolbarItem(placement: .principal) {
                Text(navigationTitle)
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                profileButton
            }
        }
        .toolbarBackground(Color.persianBlue, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) 
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
