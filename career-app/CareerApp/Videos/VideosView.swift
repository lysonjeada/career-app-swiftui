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

    @StateObject
    var coordinator: Coordinator

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView()

            case .loaded:
                videoList

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
                        page:
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
    }

    private var videoList:
        some View {

        ScrollView {
            LazyVStack(
                spacing: 14
            ) {
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
                }

                if viewModel
                    .isLoadingMore {

                    ProgressView()
                }
            }
            .padding()
        }
    }
}
