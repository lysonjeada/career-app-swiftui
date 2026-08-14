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

            do {
                _ = try await service
                    .uploadVideo(
                        title: title,
                        description:
                            description,
                        fileURL:
                            selectedVideoURL
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
