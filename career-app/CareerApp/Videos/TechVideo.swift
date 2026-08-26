//
//  TechVideo.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import Foundation

enum VideoReviewStatus:
    String,
    Codable {

    case pending
    case approved
    case rejected

    var title: String {
        switch self {
        case .pending:
            return "Em análise"

        case .approved:
            return "Aprovado"

        case .rejected:
            return "Rejeitado"
        }
    }
}


enum ThumbnailReviewStatus:
    String,
    Codable {

    case auto
    case pending
    case approved
    case rejected
}


enum VideoReactionType:
    String,
    Codable {

    case like
    case dislike
}


struct TechVideo:
    Identifiable,
    Codable {

    let id: String
    let userId: String

    let title: String
    let description: String?

    let status: VideoReviewStatus

    let rejectionReason: String?

    let createdAt: String
    let reviewedAt: String?

    let streamPath: String?

    /// Só vem preenchido quando `status == .pending`: quando o botão
    /// de reenviar a notificação de revisão volta a ficar
    /// disponível (1x por dia por vídeo).
    let nextResendAllowedAt: String?

    /// Caminho relativo da thumbnail "ao vivo" (gerada
    /// automaticamente a partir do 1º segundo do vídeo, ou última
    /// imagem customizada aprovada) — `nil` só quando nenhum frame
    /// pôde ser gerado no upload.
    let thumbnailUrl: String?

    /// Estado de uma eventual edição de thumbnail enviada pelo
    /// usuário. `thumbnailUrl` continua apontando para a imagem
    /// anterior (auto ou último approved) enquanto o status for
    /// `.pending`.
    let thumbnailStatus: ThumbnailReviewStatus

    let thumbnailRejectionReason: String?

    /// Mesmo conceito de `nextResendAllowedAt`, para o reenvio do
    /// e-mail de revisão da thumbnail pendente.
    let thumbnailNextResendAllowedAt: String?

    let likesCount: Int
    let dislikesCount: Int

    /// Reação do usuário autenticado atual — `nil` quando ele não
    /// curtiu nem descurtiu. Só vem preenchido em endpoints que
    /// calculam isso (detalhe do vídeo, reagir/favoritar, favoritos).
    let myReaction: VideoReactionType?

    let isFavorited: Bool

    var streamURL: URL? {
        guard let streamPath
        else {
            return nil
        }

        return URL(
            string:
                """
                \(APIConstants.pythonURL)\(streamPath)
                """
        )
    }

    var thumbnailURL: URL? {
        guard let thumbnailUrl
        else {
            return nil
        }

        return URL(
            string:
                """
                \(APIConstants.pythonURL)\(thumbnailUrl)
                """
        )
    }

    /// `true` quando existe uma thumbnail customizada em análise e o
    /// botão de reenvio pode ser exibido habilitado (nunca reenviado,
    /// ou já passou 24h desde o último reenvio/upload).
    var canResendThumbnailReview: Bool {
        guard thumbnailStatus == .pending
        else {
            return false
        }

        guard let date =
            Self.parseDate(
                thumbnailNextResendAllowedAt
            )
        else {
            return true
        }

        return Date() >= date
    }

    var thumbnailNextResendAllowedDate: Date? {
        Self.parseDate(
            thumbnailNextResendAllowedAt
        )
    }

    /// `true` quando o vídeo está em análise e o botão de reenvio
    /// pode ser exibido habilitado (nunca reenviado, ou já passou
    /// 24h desde o último reenvio/upload).
    var canResendReviewNotification: Bool {
        guard status == .pending
        else {
            return false
        }

        guard let date =
            Self.parseDate(
                nextResendAllowedAt
            )
        else {
            return true
        }

        return Date() >= date
    }

    var nextResendAllowedDate: Date? {
        Self.parseDate(
            nextResendAllowedAt
        )
    }

    private static func parseDate(
        _ string: String?
    ) -> Date? {
        guard let string else {
            return nil
        }

        let withFractional =
            ISO8601DateFormatter()

        withFractional.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        if let date = withFractional
            .date(from: string) {
            return date
        }

        return ISO8601DateFormatter()
            .date(from: string)
    }
}


struct VideoPageResponse:
    Codable {

    let items: [TechVideo]

    let page: Int
    let pageSize: Int

    let total: Int
    let totalPages: Int

    let hasNext: Bool
}
