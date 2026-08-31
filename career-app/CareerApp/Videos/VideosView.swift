//
//  VideosView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import SwiftUI

struct VideosView: View {
    @StateObject
    private var viewModel =
        VideosViewModel()

    let coordinator: VideosCoordinator

    @State
    private var videoPendingDeletion:
        TechVideo?

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
                        "Não foi possível carregar os vídeos",
                        systemImage:
                            "video.slash"
                    )
                } actions: {
                    Button(
                        "Tentar novamente"
                    ) {
                        viewModel.fetchVideos()
                    }
                }
            }
        }
        .navigationTitle(
            "Vídeos"
        )
        .toolbar {
            ToolbarItem(
                placement:
                    .topBarTrailing
            ) {
                Button {
                    coordinator.push(
                        .uploadVideo
                    )
                } label: {
                    Image(
                        systemName:
                            "plus"
                    )
                }
            }
        }
        .onAppear {
            viewModel.fetchVideos()
        }
        .confirmationDialog(
            "Excluir vídeo?",
            isPresented: Binding(
                get: {
                    videoPendingDeletion != nil
                },
                set: { isPresented in
                    if !isPresented {
                        videoPendingDeletion = nil
                    }
                }
            ),
            presenting: videoPendingDeletion
        ) { video in
            Button(
                "Excluir",
                role: .destructive
            ) {
                viewModel.deleteVideo(video)
                videoPendingDeletion = nil
            }

            Button(
                "Cancelar",
                role: .cancel
            ) {
                videoPendingDeletion = nil
            }
        } message: { video in
            Text(
                """
                Tem certeza que deseja excluir \
                "\(video.title)"? Essa ação não \
                pode ser desfeita.
                """
            )
        }
        .alert(
            "Não foi possível excluir",
            isPresented: Binding(
                get: {
                    viewModel.deletionErrorMessage != nil
                },
                set: { isPresented in
                    if !isPresented {
                        viewModel.clearDeletionError()
                    }
                }
            )
        ) {
            Button("OK") {
                viewModel.clearDeletionError()
            }
        } message: {
            Text(
                viewModel.deletionErrorMessage
                    ?? ""
            )
        }
    }

    private var emptyState:
        some View {

        ContentUnavailableView {
            Label(
                "Nenhum vídeo enviado",
                systemImage:
                    "video.slash"
            )
        } description: {
            Text(
                "Envie seu primeiro vídeo de apresentação para começar."
            )
        } actions: {
            Button(
                "Enviar vídeo"
            ) {
                coordinator.push(
                    .uploadVideo
                )
            }
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
                        videoPendingDeletion =
                            video
                    } label: {
                        Label(
                            "Excluir",
                            systemImage:
                                "trash"
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
