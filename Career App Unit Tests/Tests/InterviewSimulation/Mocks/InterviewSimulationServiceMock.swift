//
//  InterviewSimulationServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class InterviewSimulationServiceMock: InterviewSimulationServiceProtocol {
    var isSuccess: Bool
    var shouldThrowInsufficientCredits = false
    var savedQuestionSetsResult: [SavedQuestionSet] = []
    private(set) var receivedJobTitle: String?
    private(set) var receivedSeniority: String?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func generateQuestions(
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String] {
        receivedJobTitle = jobTitle
        receivedSeniority = seniority

        guard !shouldThrowInsufficientCredits else {
            throw APIError.insufficientCredits
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("interview-simulation-questions-response")
    }

    func transcribeAudio(fileURL: URL) async throws -> String {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return "Transcrição de teste da resposta em áudio."
    }

    func evaluateSimulation(
        jobTitle: String,
        seniority: String,
        answers: [InterviewSimulationAnswer]
    ) async throws -> InterviewSimulationEvaluation {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("interview-simulation-evaluation-response")
    }

    func saveGeneratedQuestions(
        jobTitle: String,
        seniority: String,
        questions: [String]
    ) async throws -> SaveGeneratedQuestionsResponse {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("interview-simulation-save-questions-response")
    }

    func fetchSavedQuestions() async throws -> [SavedQuestionSet] {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return savedQuestionSetsResult
    }
}
