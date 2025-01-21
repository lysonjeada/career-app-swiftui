//
//  FullArticleListView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 30/10/24.
//

import SwiftUI

struct FullArticleListView: View {
    let articles: [Article]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(articles) { article in
                        VStack(alignment: .leading, spacing: 8) {
                            // Imagem do artigo
                            let coverImageUrl = article.cover_image ?? ""
                            if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 180)
                                        .clipped()
                                        .cornerRadius(10)
                                } placeholder: {
                                    Image("no-image-available")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 180)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            } else {
                                Image("no-image-available")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                            
                            // Título e descrição do artigo
                            Text(article.title)
                                .font(.headline)
                                .lineLimit(2)
                            
                            Text(article.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                            
                            // Informações adicionais (data e autor)
                            HStack {
                                Text(article.readable_publish_date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("by \(article.user.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .onTapGesture {
                            if let url = URL(string: article.url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Todos os Artigos")
        }
    }
}
