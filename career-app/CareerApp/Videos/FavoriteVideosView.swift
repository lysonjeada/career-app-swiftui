//
//  FavoriteVideosView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/08/26.
//

import SwiftUI

struct FavoriteVideosView: View {
    @StateObject
    private var viewModel =
        FavoriteVideosViewModel()

    @StateObject
    var coordinator: Coordinator

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()

            case .loaded:
                if viewModel.videos.isEmpty {
                    emptyState
                } else {
                    videoList
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
        .navigationTitle(
            "Favoritos"
        )
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
                "Nenhum vídeo favoritado",
                systemImage:
                    "star.slash"
            )
        } description: {
            Text(
                "Toque na estrela na tela de um vídeo para favoritá-lo."
            )
        }
    }

    private var videoList:
        some View {

        List {
            ForEach(
                viewModel.videos
            ) { video in

                Button {
                    coordinator.push(
                        page:
                            .videoDetail(
                                videoId:
                                    video.id
                            )
                    )

                } label: {
                    VideoRow(
                        video: video
                    )
                }
                .buttonStyle(
                    .plain
                )
                .onAppear {
                    viewModel
                        .loadMoreIfNeeded(
                            video: video
                        )
                }
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
                            video
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

            if viewModel
                .isLoadingMore {

                ProgressView()
                    .frame(
                        maxWidth: .infinity
                    )
                    .listRowSeparator(
                        .hidden
                    )
                    .listRowBackground(
                        Color.clear
                    )
            }
        }
        .listStyle(.plain)
    }
}
