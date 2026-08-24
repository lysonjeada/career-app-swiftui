//
//  InterviewServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class InterviewServiceMock: InterviewServiceProtocol {
    var isSuccess: Bool
    var shouldThrowInsufficientCredits = false
    private(set) var receivedFetchResumeFeedbackURL: URL?
    private(set) var receivedSubmitFeedbackURL: URL?
    private(set) var receivedCheckStatusTaskID: String?
    private(set) var receivedFetchResultTaskID: String?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func fetchResumeFeedback(resumeURL: URL) async throws -> ResumeFeedbackResponse {
        receivedFetchResumeFeedbackURL = resumeURL

        guard !shouldThrowInsufficientCredits else {
            throw APIError.insufficientCredits
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("resume-feedback-response")
    }

    func submitFeedbackAndGetTaskID(resumeURL: URL) async throws -> String {
        receivedSubmitFeedbackURL = resumeURL

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return "task-123"
    }

    func checkFeedbackStatus(taskID: String) async throws -> Bool {
        receivedCheckStatusTaskID = taskID

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return true
    }

    func fetchFeedbackResult(taskID: String) async throws -> String {
        receivedFetchResultTaskID = taskID

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        let response: ResumeFeedbackResponse = try JSONLoader.load("resume-feedback-response")
        return response.feedback
    }
}
