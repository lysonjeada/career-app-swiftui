//
//  FullArticleListView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 30/10/24.
//

import SwiftUI

struct FullArticleListView: View {
    let articles: [Article]

    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(articles) { article in
                        articleCard(article)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("Todos os Artigos")
        }
    }

    // MARK: - Article Card

    @ViewBuilder
    private func articleCard(_ article: Article) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            articleImage(article)

            Text(article.title)
                .font(.headline)
                .lineLimit(2)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            articleDescription(article)

            HStack(spacing: 8) {
                Text(article.readable_publish_date)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("by \(article.user.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(16)
        .background(
            Color(uiColor: .systemGray6)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10
            )
        )
        .shadow(radius: 5)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: article.url) {
                openURL(url)
            }
        }
    }

    // MARK: - Image

    @ViewBuilder
    private func articleImage(_ article: Article) -> some View {
        let coverImageURL = article.cover_image ?? ""

        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .overlay {
                if let url = URL(string: coverImageURL),
                   !coverImageURL.isEmpty {

                    AsyncImage(url: url) { phase in
                        switch phase {

                        case .empty:
                            placeholderImage

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()

                        case .failure:
                            placeholderImage

                        @unknown default:
                            placeholderImage
                        }
                    }

                } else {
                    placeholderImage
                }
            }
            .clipped()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10
                )
            )
    }

    // MARK: - Placeholder

    private var placeholderImage: some View {
        Image("no-image-available")
            .resizable()
            .scaledToFill()
    }

    // MARK: - Description

    @ViewBuilder
    private func articleDescription(_ article: Article) -> some View {
        let description = article.description
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if description.count < 4 {
            Text("""
                No description available
                Click to see more details
                Read the full article
                """)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        } else {
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}
