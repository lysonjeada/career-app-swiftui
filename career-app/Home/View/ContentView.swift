//
//  ContentView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 12/08/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var deepLinkManager = DeepLinkManager()
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        TabView(selection: $deepLinkManager.selectedTab) {
            HomeView(viewModel: viewModel, output: .init(goToMainScreen: { }, goToForgotPassword: { }))
                .tabItem {
                    Label(HomeStrings.homeTitle, systemImage: "doc.text")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.home)
            
            InterviewGenerateQuestionsView(viewModel: GenerateQuestionsViewModel())
                .tabItem {
                    Label(HomeStrings.interviewTitle, systemImage: "mic.fill")
                        .foregroundColor(.persianBlue)
                }
                .tag(TabSelection.interview)
            
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
        
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .articleDetail(let articleId):
                ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: articleId))
            }
        }
        
        //        .environmentObject(deepLinkManager)
    }
}

struct CurriculumView: View {
    var body: some View {
        Text("Curriculum View")
            .font(.largeTitle)
            .navigationTitle("Curriculum")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
