//
//  VideoThumbnailGenerator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/08/26.
//

import AVFoundation
import UIKit

enum VideoThumbnailGenerator {

    /// Extrai um frame próximo do 1º segundo do vídeo local em
    /// `url` e devolve como JPEG — usado como thumbnail automática
    /// quando o usuário não escolhe uma imagem própria (e como
    /// fallback caso a customizada seja rejeitada na revisão).
    static func generateFirstFrameJPEG(
        from url: URL,
        compressionQuality: CGFloat = 0.7
    ) async -> Data? {
        let asset = AVURLAsset(url: url)

        let generator = AVAssetImageGenerator(
            asset: asset
        )

        generator.appliesPreferredTrackTransform = true

        let requestedTime = CMTime(
            seconds: 1,
            preferredTimescale: 600
        )

        do {
            let duration = try await asset.load(.duration)

            let time = min(
                requestedTime,
                duration
            )

            let cgImage = try await generator.image(
                at: time
            ).image

            return UIImage(cgImage: cgImage)
                .jpegData(
                    compressionQuality:
                        compressionQuality
                )

        } catch {
            print(
                """
                ⚠️ Não foi possível gerar a thumbnail
                automática do vídeo:

                \(error)
                """
            )

            return nil
        }
    }
}
