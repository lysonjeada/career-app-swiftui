//
//  StudyPlanServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class StudyPlanServiceMock: StudyPlanServiceProtocol {
    var isSuccess: Bool
    var shouldThrowInsufficientCredits = false
    private(set) var receivedJobTitle: String?
    private(set) var receivedSeniority: String?
    private(set) var callCount = 0

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func generateStudyPlan(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) async throws -> StudyPlan {
        callCount += 1
        receivedJobTitle = jobTitle
        receivedSeniority = seniority

        guard !shouldThrowInsufficientCredits else {
            throw APIError.insufficientCredits
        }

        guard isSuccess else {
            throw StudyPlanServiceError.serverError(statusCode: 500, message: "Erro simulado.")
        }

        let dto: StudyPlanFixtureDTO = try JSONLoader.load("study-plan-response")
        return dto.toDomain()
    }
}

private struct StudyPlanFixtureDTO: Decodable {
    let title: String
    let summary: String
    let estimatedTotalHours: Int
    let topics: [StudyPlanTopicFixtureDTO]

    func toDomain() -> StudyPlan {
        StudyPlan(
            title: title,
            summary: summary,
            estimatedTotalHours: estimatedTotalHours,
            topics: topics.map { $0.toDomain() }
        )
    }
}

private struct StudyPlanTopicFixtureDTO: Decodable {
    let title: String
    let description: String
    let priority: String
    let estimatedHours: Int
    let subtopics: [String]
    let practice: String

    func toDomain() -> StudyPlanTopic {
        StudyPlanTopic(
            title: title,
            description: description,
            priority: StudyPlanPriority(rawValue: priority) ?? .medium,
            estimatedHours: estimatedHours,
            subtopics: subtopics,
            practice: practice
        )
    }
}
