//
//  InterviewSimulationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import Foundation

protocol InterviewSimulationServiceProtocol {
    func generateQuestions(
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String]

    func transcribeAudio(
        fileURL: URL
    ) async throws -> String

    func evaluateSimulation(
        jobTitle: String,
        seniority: String,
        answers: [InterviewSimulationAnswer]
    ) async throws -> InterviewSimulationEvaluation
}

final class InterviewSimulationService:
    InterviewSimulationServiceProtocol {

    func generateQuestions(
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String] {
        let requestBody = GenerateQuestionsRequest(
            jobTitle: jobTitle,
            seniority: seniority,
            description: description.isEmpty ? nil : description
        )

        let response: GenerateQuestionsResponse = try await sendJSONRequest(
            path: "/interview-simulation/questions",
            body: requestBody
        )

        return response.questions
    }

    func transcribeAudio(
        fileURL: URL
    ) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"

        guard let url = URL(
            string: "\(APIConstants.pythonURL)/interview-simulation/transcribe"
        ) else {
            throw InterviewSimulationServiceError.invalidURL
        }

        let audioData = try Data(contentsOf: fileURL)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.appendString("--\(boundary)\r\n")

        body.appendString(
            """
            Content-Disposition: form-data; name="audio"; filename="answer.m4a"\r\n
            """
        )

        body.appendString("Content-Type: audio/mp4\r\n\r\n")
        body.append(audioData)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(
            TranscriptionResponse.self,
            from: data
        )

        return decoded.transcript
    }

    func evaluateSimulation(
        jobTitle: String,
        seniority: String,
        answers: [InterviewSimulationAnswer]
    ) async throws -> InterviewSimulationEvaluation {
        let answerDTOs = answers.map {
            EvaluationAnswerRequest(
                question: $0.question,
                answer: $0.answer,
                responseTimeSeconds: $0.responseTimeSeconds
            )
        }

        let requestBody = EvaluationRequest(
            jobTitle: jobTitle,
            seniority: seniority,
            answers: answerDTOs
        )

        return try await sendJSONRequest(
            path: "/interview-simulation/evaluate",
            body: requestBody
        )
    }

    private func sendJSONRequest<Request: Encodable, Response: Decodable>(
        path: String,
        body: Request
    ) async throws -> Response {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)\(path)"
        ) else {
            throw InterviewSimulationServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 120

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        try validate(response: response, data: data)

        return try JSONDecoder().decode(
            Response.self,
            from: data
        )
    }

    private func validate(
        response: URLResponse,
        data: Data
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw InterviewSimulationServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let message = String(
                data: data,
                encoding: .utf8
            )

            throw InterviewSimulationServiceError.serverError(
                statusCode: httpResponse.statusCode,
                message: message
            )
        }
    }
}

private struct GenerateQuestionsRequest: Encodable {
    let jobTitle: String
    let seniority: String
    let description: String?

    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case seniority
        case description
    }
}

private struct GenerateQuestionsResponse: Decodable {
    let questions: [String]
}

private struct TranscriptionResponse: Decodable {
    let transcript: String
}

private struct EvaluationRequest: Encodable {
    let jobTitle: String
    let seniority: String
    let answers: [EvaluationAnswerRequest]

    enum CodingKeys: String, CodingKey {
        case jobTitle = "job_title"
        case seniority
        case answers
    }
}

private struct EvaluationAnswerRequest: Encodable {
    let question: String
    let answer: String
    let responseTimeSeconds: Int

    enum CodingKeys: String, CodingKey {
        case question
        case answer
        case responseTimeSeconds = "response_time_seconds"
    }
}

private enum InterviewSimulationServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL do servidor é inválida."

        case .invalidResponse:
            return "O servidor retornou uma resposta inválida."

        case let .serverError(statusCode, message):
            return """
            Erro \(statusCode): \(message ?? "Erro desconhecido.")
            """
        }
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }

        append(data)
    }
}
