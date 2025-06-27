//
//  ArticlesHorizontalList.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

struct ArticlesHorizontalList: View {
    @StateObject var viewModel: HomeViewModel
    @StateObject var coordinator: Coordinator
    @Binding var showFullArticleList: Bool
    
    private let articleLimit = 10
    private let availableTags = ["Todos", "swift", "ios", "xcode", "apple"]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 8) {
                Text("Artigos")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.titleSectionColor)
                tagPicker
            }
            .padding(.bottom, 1)
            
            Button(action: {
                if let url = URL(string: "https://dev.to/") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Text("Abrir dev.to")
                        .font(.system(size: 12))
                        .foregroundColor(Color.persianBlue)
                        .shadow(radius: 0.5)
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundColor(Color.persianBlue)
                        .shadow(radius: 0.5)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.articles.prefix(articleLimit)) { article in
                        ArticleCard(article: article)
                            .frame(width: 200)
                            .padding(.vertical, 2)
                            .onTapGesture {
                                coordinator.push(page: .articleDetail(id: article.id))
                            }
                    }
                    buildShowMoreButton()
                }
            }
            .padding(.top, 2)
            
            Divider()
        }
    }
    
    private var tagPicker: some View {
        Menu {
            ForEach(availableTags, id: \.self) { tag in
                Button(action: {
                    viewModel.selectedTag = tag
                    let tagToFetch = tag == "Todos" ? nil : tag
                    viewModel.fetchArticles(tag: tagToFetch)
                }) {
                    HStack {
                        Text(tag.capitalized)
                        if viewModel.selectedTag == tag {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            VStack {
                HStack {
                    Text(viewModel.selectedTag.capitalized)
                        .font(.subheadline)
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
                .padding(8)
                .cornerRadius(10)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.persianBlue, lineWidth: 2)
            )
            .padding()
        }
    }
    
    @ViewBuilder
    func buildShowMoreButton() -> some View {
        if viewModel.articles.count > articleLimit {
            Button(action: {
                showFullArticleList.toggle()
            }) {
                Text("Ver Mais")
                    .font(.headline)
                    .padding()
                    .frame(width: 120, height: 120)
                    .background(Color.clear)
                    .foregroundColor(Color.persianBlue)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.persianBlue, lineWidth: 2)
                    )
            }
            .padding(.trailing, 16)
            .shadow(radius: 1)
            .sheet(isPresented: $showFullArticleList) {
                FullArticleListView(articles: viewModel.articles)
            }
        }
    }
}
