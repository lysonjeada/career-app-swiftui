//
//  SaveGeneratedQuestionsResponse.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import Foundation

enum SaveGeneratedQuestionsState: Equatable {
    case idle
    case saving
    case saved(Int)
    case error(String)
}

struct SaveGeneratedQuestionsResponse: Decodable {
    let id: UUID
    let savedCount: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case id
        case savedCount = "saved_count"
        case message
    }
}
