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
