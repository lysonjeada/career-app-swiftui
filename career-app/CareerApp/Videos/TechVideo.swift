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
