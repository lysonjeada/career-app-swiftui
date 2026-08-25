//
//  UploadVideoView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import AVKit
import PhotosUI
import SwiftUI

struct UploadVideoView: View {
    @StateObject
    private var viewModel =
        UploadVideoViewModel()

    @StateObject
    var coordinator: Coordinator

    @State
    private var selectedItem:
        PhotosPickerItem?

    @State
    private var selectedThumbnailItem:
        PhotosPickerItem?

    @State
    private var player:
        AVPlayer?

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 20
            ) {
                TextField(
                    "Título",
                    text:
                        $viewModel.title
                )
                .textFieldStyle(
                    .roundedBorder
                )

                TextField(
                    "Descrição",
                    text:
                        $viewModel.description,
                    axis: .vertical
                )
                .lineLimit(
                    4...8
                )
                .textFieldStyle(
                    .roundedBorder
                )

                PhotosPicker(
                    selection:
                        $selectedItem,
                    matching:
                        .videos
                ) {
                    Label(
                        viewModel
                            .selectedVideoURL
                        == nil
                        ? "Selecionar vídeo"
                        : "Vídeo selecionado",
                        systemImage:
                            "video.badge.plus"
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                    .padding()
                    .background(
                        Color.persianBlue
                            .opacity(0.15)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                }

                if let player {
                    VideoPlayer(
                        player: player
                    )
                    .frame(
                        height: 220
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )

                    Text(
                        "Confira se este é o vídeo certo antes de enviar."
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                PhotosPicker(
                    selection:
                        $selectedThumbnailItem,
                    matching:
                        .images
                ) {
                    Label(
                        viewModel
                            .customThumbnailData
                        == nil
                        ? "Escolher thumbnail (opcional)"
                        : "Thumbnail escolhida",
                        systemImage:
                            "photo.badge.plus"
                    )
                    .frame(
                        maxWidth:
                            .infinity
                    )
                    .padding()
                    .background(
                        Color.persianBlue
                            .opacity(0.15)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                }

                if let thumbnailData =
                    viewModel.customThumbnailData,
                   let uiImage =
                    UIImage(data: thumbnailData) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .frame(
                            maxWidth: .infinity
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14
                            )
                        )
                        .clipped()

                    Text(
                        "Sua thumbnail passará por uma revisão antes de ficar visível para todos."
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }

                if let error =
                    viewModel.errorMessage {

                    Text(error)
                        .foregroundStyle(
                            .red
                        )
                }

                Button {
                    viewModel.upload()

                } label: {
                    if viewModel
                        .isUploading {

                        ProgressView()
                            .tint(.white)

                    } else {
                        Text(
                            "Enviar para análise"
                        )
                        .bold()
                    }
                }
                .frame(
                    maxWidth:
                        .infinity
                )
                .padding()
                .background(
                    Color.persianBlue
                )
                .foregroundStyle(
                    .white
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14
                    )
                )
                .disabled(
                    viewModel.isUploading
                )
            }
            .padding()
        }
        .navigationTitle(
            "Novo vídeo"
        )
        .onDisappear {
            VideoPlaybackAudioSession
                .deactivate()
        }
        .onChange(
            of: selectedItem
        ) {
            _,
            item in

            guard let item
            else {
                return
            }

            Task {
                if let movie =
                    try? await item
                        .loadTransferable(
                            type:
                                PickedMovie.self
                        ) {

                    viewModel.selectVideo(
                        movie.url
                    )

                    VideoPlaybackAudioSession
                        .activate()

                    player = AVPlayer(
                        url: movie.url
                    )
                }
            }
        }
        .onChange(
            of: selectedThumbnailItem
        ) {
            _,
            item in

            guard let item
            else {
                return
            }

            Task {
                if let data =
                    try? await item
                        .loadTransferable(
                            type: Data.self
                        ) {

                    viewModel.selectThumbnail(
                        data
                    )
                }
            }
        }
        .onChange(
            of:
                viewModel.didUpload
        ) {
            _,
            didUpload in

            guard didUpload else {
                return
            }

            coordinator.pop()
        }
    }
}
