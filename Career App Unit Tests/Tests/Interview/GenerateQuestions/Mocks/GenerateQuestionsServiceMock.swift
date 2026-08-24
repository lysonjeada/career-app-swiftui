//
//  GenerateQuestionsServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class GenerateQuestionsServiceMock: GenerateQuestionsServiceProtocol {
    var isSuccess: Bool
    var shouldThrowInsufficientCredits = false
    private(set) var receivedResumeURL: URL?
    private(set) var receivedJobTitle: String?
    private(set) var receivedSeniority: String?
    private(set) var receivedDescription: String?
    private(set) var callCount = 0

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func generateQuestions(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String] {
        callCount += 1
        receivedResumeURL = resumeURL
        receivedJobTitle = jobTitle
        receivedSeniority = seniority
        receivedDescription = description

        guard !shouldThrowInsufficientCredits else {
            throw APIError.insufficientCredits
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        let response: QuestionResponse = try JSONLoader.load("generate-questions-response")
        return response.questions
    }
}
