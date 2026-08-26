//
//  FavoriteArticlesView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/08/26.
//

import SwiftUI

struct FavoriteArticlesView: View {
    @StateObject
    private var viewModel =
        FavoriteArticlesViewModel()

    var onSelect: (Int) -> Void

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()

            case .loaded:
                if viewModel.articles.isEmpty {
                    emptyState
                } else {
                    articleList
                }

            case .error:
                ContentUnavailableView {
                    Label(
                        "Não foi possível carregar os favoritos",
                        systemImage:
                            "star.slash"
                    )
                } actions: {
                    Button(
                        "Tentar novamente"
                    ) {
                        viewModel.fetchFavorites()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchFavorites()
        }
        .alert(
            "Não foi possível remover",
            isPresented: Binding(
                get: {
                    viewModel.removalErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearRemovalError()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.clearRemovalError()
            }
        } message: {
            Text(
                viewModel.removalErrorMessage
                    ?? ""
            )
        }
    }

    private var emptyState:
        some View {

        ContentUnavailableView {
            Label(
                "Nenhum artigo favoritado",
                systemImage:
                    "star.slash"
            )
        } description: {
            Text(
                "Toque na estrela na tela de um artigo para favoritá-lo."
            )
        }
    }

    private var articleList:
        some View {

        List {
            ForEach(
                viewModel.articles,
                id: \.id
            ) { article in

                Button {
                    if let id = article.id {
                        onSelect(id)
                    }
                } label: {
                    ArticleFavoriteRow(
                        article: article
                    )
                }
                .buttonStyle(
                    .plain
                )
                .listRowSeparator(
                    .hidden
                )
                .listRowBackground(
                    Color.clear
                )
                .listRowInsets(
                    EdgeInsets(
                        top: 7,
                        leading: 16,
                        bottom: 7,
                        trailing: 16
                    )
                )
                .swipeActions(
                    edge: .trailing,
                    allowsFullSwipe: true
                ) {
                    Button(
                        role: .destructive
                    ) {
                        viewModel.removeFavorite(
                            article
                        )
                    } label: {
                        Label(
                            "Remover",
                            systemImage:
                                "star.slash"
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct ArticleFavoriteRow: View {
    let article: ArticleDetail

    var body: some View {
        HStack(
            spacing: 16
        ) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: 14
                )
                .fill(
                    Color.persianBlue
                        .opacity(0.12)
                )

                if let coverImage = article.coverImage,
                   let url = URL(string: coverImage) {

                    AsyncImage(
                        url: url
                    ) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(
                            systemName:
                                "doc.text"
                        )
                        .foregroundStyle(
                            Color.persianBlue
                        )
                    }
                    .frame(
                        width: 80,
                        height: 70
                    )
                    .clipped()

                } else {
                    Image(
                        systemName:
                            "doc.text"
                    )
                    .font(.title)
                    .foregroundStyle(
                        Color.persianBlue
                    )
                }
            }
            .frame(
                width: 80,
                height: 70
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14
                )
            )

            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text(
                    article.title
                        ?? "Artigo"
                )
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(
                    .primary
                )

                if let name =
                    article.user?.name {

                    Text(name)
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                }
            }

            Spacer()

            Image(
                systemName:
                    "chevron.right"
            )
            .foregroundStyle(
                .secondary
            )
        }
        .padding()
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
}
