//
//  InterviewSimulationQuestion.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import Foundation

struct InterviewSimulationQuestion: Identifiable, Equatable {
    let id: UUID
    let text: String

    init(
        id: UUID = UUID(),
        text: String
    ) {
        self.id = id
        self.text = text
    }
}

enum InterviewAnswerInputType: String, Codable, CaseIterable, Identifiable {
    case text
    case audio

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .text:
            return "Texto"

        case .audio:
            return "Áudio"
        }
    }

    var icon: String {
        switch self {
        case .text:
            return "keyboard"

        case .audio:
            return "mic.fill"
        }
    }
}

struct InterviewSimulationAnswer: Identifiable, Codable, Equatable {
    let id: UUID
    let question: String
    let answer: String
    let responseTimeSeconds: Int
    let inputType: InterviewAnswerInputType

    init(
        id: UUID = UUID(),
        question: String,
        answer: String,
        responseTimeSeconds: Int,
        inputType: InterviewAnswerInputType
    ) {
        self.id = id
        self.question = question
        self.answer = answer
        self.responseTimeSeconds = responseTimeSeconds
        self.inputType = inputType
    }

    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
        case responseTimeSeconds = "response_time_seconds"
        case inputType = "input_type"
    }
}

struct InterviewSimulationEvaluation: Decodable, Equatable {
    let clarity: Int
    let objectivity: Int
    let examples: Int
    let technicalKnowledge: Int
    let responseTime: Int
    let overall: Int
    let summary: String
    let strengths: [String]
    let improvements: [String]

    enum CodingKeys: String, CodingKey {
        case clarity
        case objectivity
        case examples
        case technicalKnowledge = "technical_knowledge"
        case responseTime = "response_time"
        case overall
        case summary
        case strengths
        case improvements
    }
}
