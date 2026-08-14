//
//  Tutor.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation

struct Tutor: Identifiable, Codable {
    let id: String
    let userId: String?

    let name: String
    let profession: String

    let yearsOfExperience: Int

    let levels: [String]

    let hourlyRate: Double

    let language: String

    let profileImageUrl: String?

    let bio: String?
}

struct TutorPageResponse: Codable {
    let items: [Tutor]

    let page: Int
    let pageSize: Int

    let total: Int
    let totalPages: Int

    let hasNext: Bool
    let hasPrevious: Bool
}
