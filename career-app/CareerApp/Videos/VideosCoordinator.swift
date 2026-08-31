//
//  VideosCoordinator.swift
//  career-app
//

import SwiftUI

/// Navegação do fluxo de vídeos (lista, upload, detalhe) — empurra no
/// `path` compartilhado do Coordinator raiz. Favoritos fica de fora
/// porque mistura vídeos e artigos (rota fica no Coordinator raiz).
@MainActor
final class VideosCoordinator {
    weak var root: Coordinator?

    func push(_ route: VideosRoute) {
        root?.path.append(route)
    }

    func pop() {
        root?.pop()
    }

    @ViewBuilder
    func build(_ route: VideosRoute) -> some View {
        switch route {
        case .videos:
            VideosView(coordinator: self)

        case .uploadVideo:
            UploadVideoView(coordinator: self)

        case .videoDetail(let videoId):
            VideoDetailView(videoId: videoId)
        }
    }
}

enum VideosRoute: Hashable {
    case videos
    case uploadVideo
    case videoDetail(videoId: String)
}
