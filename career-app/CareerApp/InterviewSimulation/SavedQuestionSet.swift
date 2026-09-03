//
//  SavedQuestionSet.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 02/09/26.
//

import Foundation

struct SavedQuestionSet: Decodable, Identifiable {
    let id: UUID
    let jobTitle: String
    let seniority: String
    let questions: [String]
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case jobTitle = "job_title"
        case seniority
        case questions
        case createdAt = "created_at"
    }

    var createdDate: Date? {
        let withFractional = ISO8601DateFormatter()

        withFractional.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds,
        ]

        if let date = withFractional.date(from: createdAt) {
            return date
        }

        if let date = ISO8601DateFormatter().date(from: createdAt) {
            return date
        }

        return DateFormatter.iso8601BackendDateTimeFormatter.date(from: createdAt)
    }
}
