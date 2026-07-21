//
//  InterviewSimulationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 21/07/26.
//

import Foundation

@MainActor
final class InterviewSimulationViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loadingQuestions
        case answering
        case transcribing
        case evaluating
        case completed
        case evaluationFailed
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var questions: [InterviewSimulationQuestion] = []
    @Published private(set) var answers: [InterviewSimulationAnswer] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var elapsedSeconds: Int = 0
    @Published private(set) var evaluation: InterviewSimulationEvaluation?

    @Published var currentAnswer: String = ""
    @Published var answerInputType: InterviewAnswerInputType = .text
    @Published var errorMessage: String?

    private let service: InterviewSimulationServiceProtocol

    private var timerTask: Task<Void, Never>?

    private var jobTitle: String = ""
    private var seniority: String = ""
    private var jobDescription: String = ""

    init(
        service: InterviewSimulationServiceProtocol =
            InterviewSimulationService()
    ) {
        self.service = service
    }

    var currentQuestion: InterviewSimulationQuestion? {
        guard questions.indices.contains(currentIndex) else {
            return nil
        }

        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else {
            return 0
        }

        return Double(currentIndex + 1) /
            Double(questions.count)
    }

    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    var formattedElapsedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60

        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }

    func startSimulation(
        jobTitle: String,
        seniority: String,
        description: String
    ) async {
        let normalizedJobTitle = jobTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let normalizedSeniority = seniority.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalizedJobTitle.isEmpty else {
            errorMessage = "Informe o cargo da entrevista."
            return
        }

        guard !normalizedSeniority.isEmpty,
              normalizedSeniority != "Senioridade" else {
            errorMessage = "Selecione a senioridade."
            return
        }

        self.jobTitle = normalizedJobTitle
        self.seniority = normalizedSeniority
        self.jobDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        state = .loadingQuestions
        questions = []
        answers = []
        evaluation = nil

        do {
            let generatedQuestions = try await service.generateQuestions(
                jobTitle: self.jobTitle,
                seniority: self.seniority,
                description: self.jobDescription
            )

            let validQuestions = generatedQuestions
                .map {
                    $0.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                }
                .filter {
                    !$0.isEmpty
                }

            guard !validQuestions.isEmpty else {
                throw InterviewSimulationViewModelError.noQuestions
            }

            questions = validQuestions.map {
                InterviewSimulationQuestion(text: $0)
            }

            currentIndex = 0
            currentAnswer = ""
            answerInputType = .text
            state = .answering

            startTimer(reset: true)

        } catch {
            state = .idle
            errorMessage = error.localizedDescription
        }
    }

    func submitTextAnswer() async {
        await saveAnswer(
            currentAnswer,
            inputType: .text,
            responseTime: elapsedSeconds
        )
    }

    func submitAudioAnswer(
        fileURL: URL
    ) async {
        timerTask?.cancel()

        let responseTime = elapsedSeconds

        state = .transcribing

        do {
            let transcript = try await service.transcribeAudio(
                fileURL: fileURL
            )

            currentAnswer = transcript

            await saveAnswer(
                transcript,
                inputType: .audio,
                responseTime: responseTime
            )

        } catch {
            state = .answering
            errorMessage = error.localizedDescription

            startTimer(reset: false)
        }
    }

    func retryEvaluation() async {
        await evaluateAnswers()
    }

    func restart() {
        timerTask?.cancel()

        state = .idle
        questions = []
        answers = []
        currentIndex = 0
        elapsedSeconds = 0
        currentAnswer = ""
        answerInputType = .text
        evaluation = nil
        errorMessage = nil
    }

    func clearError() {
        errorMessage = nil
    }

    func showError(_ message: String) {
        errorMessage = message
    }

    private func saveAnswer(
        _ answer: String,
        inputType: InterviewAnswerInputType,
        responseTime: Int
    ) async {
        let normalizedAnswer = answer.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !normalizedAnswer.isEmpty else {
            state = .answering
            errorMessage = "Digite ou grave uma resposta."
            return
        }

        guard let question = currentQuestion else {
            return
        }

        timerTask?.cancel()

        let simulationAnswer = InterviewSimulationAnswer(
            question: question.text,
            answer: normalizedAnswer,
            responseTimeSeconds: responseTime,
            inputType: inputType
        )

        answers.append(simulationAnswer)

        if isLastQuestion {
            await evaluateAnswers()
            return
        }

        currentIndex += 1
        currentAnswer = ""
        answerInputType = .text

        state = .answering
        startTimer(reset: true)
    }

    private func evaluateAnswers() async {
        timerTask?.cancel()
        state = .evaluating

        do {
            evaluation = try await service.evaluateSimulation(
                jobTitle: jobTitle,
                seniority: seniority,
                answers: answers
            )

            state = .completed

        } catch {
            errorMessage = error.localizedDescription
            state = .evaluationFailed
        }
    }

    private func startTimer(
        reset: Bool
    ) {
        timerTask?.cancel()

        if reset {
            elapsedSeconds = 0
        }

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(
                    nanoseconds: 1_000_000_000
                )

                guard !Task.isCancelled else {
                    return
                }

                self?.elapsedSeconds += 1
            }
        }
    }
}

private enum InterviewSimulationViewModelError: LocalizedError {
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .noQuestions:
            return "Nenhuma pergunta foi gerada."
        }
    }
}
