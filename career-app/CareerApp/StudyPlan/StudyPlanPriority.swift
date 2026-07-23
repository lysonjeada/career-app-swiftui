//
//  StudyPlanPriority.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import Foundation

enum StudyPlanPriority: String, Codable, Equatable {
    case high
    case medium
    case low

    var title: String {
        switch self {
        case .high:
            return "Alta prioridade"

        case .medium:
            return "Média prioridade"

        case .low:
            return "Baixa prioridade"
        }
    }

    var icon: String {
        switch self {
        case .high:
            return "exclamationmark.circle.fill"

        case .medium:
            return "minus.circle.fill"

        case .low:
            return "arrow.down.circle.fill"
        }
    }
}

struct StudyPlan: Equatable {
    let title: String
    let summary: String
    let estimatedTotalHours: Int
    var topics: [StudyPlanTopic]
}

struct StudyPlanTopic: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let priority: StudyPlanPriority
    let estimatedHours: Int
    let subtopics: [String]
    let practice: String

    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        priority: StudyPlanPriority,
        estimatedHours: Int,
        subtopics: [String],
        practice: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.estimatedHours = estimatedHours
        self.subtopics = subtopics
        self.practice = practice
        self.isCompleted = isCompleted
    }
}
