//
//  UploadVideoViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import Foundation

@MainActor
final class UploadVideoViewModel:
    ObservableObject {

    @Published
    var title = ""

    @Published
    var description = ""

    @Published private(set)
    var selectedVideoURL:
        URL?

    /// Imagem escolhida pelo usuário para a thumbnail (opcional). Se
    /// `nil`, o upload usa só o frame gerado automaticamente a
    /// partir do vídeo.
    @Published private(set)
    var customThumbnailData:
        Data?

    @Published private(set)
    var isUploading =
        false

    @Published private(set)
    var didUpload =
        false

    @Published private(set)
    var errorMessage:
        String?

    private let service:
        VideoServiceProtocol

    init(
        service:
            VideoServiceProtocol =
            VideoService()
    ) {
        self.service =
            service
    }

    func selectVideo(
        _ url: URL
    ) {
        selectedVideoURL =
            url
    }

    func selectThumbnail(
        _ data: Data
    ) {
        customThumbnailData =
            data
    }

    func upload() {
        guard
            !title
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .isEmpty,
            let selectedVideoURL
        else {
            errorMessage =
                "Informe o título e escolha um vídeo."

            return
        }

        isUploading =
            true

        errorMessage =
            nil

        Task {
            defer {
                isUploading =
                    false
            }

            let autoThumbnailData =
                await VideoThumbnailGenerator
                    .generateFirstFrameJPEG(
                        from: selectedVideoURL
                    )

            do {
                _ = try await service
                    .uploadVideo(
                        title: title,
                        description:
                            description,
                        fileURL:
                            selectedVideoURL,
                        autoThumbnailData:
                            autoThumbnailData,
                        customThumbnailData:
                            customThumbnailData
                    )

                didUpload =
                    true

            } catch {
                errorMessage =
                    error.localizedDescription
            }
        }
    }
}
