//
//  CoordinatorView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/03/25.
//

import SwiftUI

struct CoordinatorView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject private var deepLinkManager: DeepLinkManager
    @State private var searchText = ""
    
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
        NavigationStack(path: $coordinator.path) {
            coordinator.buildRootView()
                .navigationDestination(for: AppPages.self) { page in
                    coordinator.build(page: page)
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .articleDetail(let articleId):
                        ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: articleId))
                    }
                }
        }
        
    }
}
