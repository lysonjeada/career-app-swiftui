//
//  GenerateQuestionsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI
import Foundation

import SwiftUI
import Foundation

struct QuestionsGeneratorStep: Codable {
    let steps: [Step]

    struct Step: Codable, Identifiable, Hashable {
        var id = UUID()
        let title: String
        let description: String?
        let imageButton: String
        let type: StepType

        enum StepType: Codable, Hashable {
            case addCurriculum
            case addInfoJob
            case addDescriptionJob
        }

        enum CodingKeys: String, CodingKey {
            case title
            case description
            case imageButton
            case type
        }
    }
}

@MainActor
final class GenerateQuestionsViewModel: ObservableObject {

    @Published private(set) var generatedQuestions: [String] = []
    @Published private(set) var viewState: State = .idle
    @Published private(set) var saveQuestionsState: SaveGeneratedQuestionsState = .idle

    private(set) var steps: [QuestionsGeneratorStep.Step]
    private(set) var lastJobTitle = ""
    private(set) var lastSeniority = ""

    private var task: Task<Void, Never>?

    private let service: GenerateQuestionsServiceProtocol
    private let interviewSimulationService: InterviewSimulationServiceProtocol

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        case insufficientCredits
    }

    init(
        service: GenerateQuestionsServiceProtocol = GenerateQuestionsService(),
        interviewSimulationService: InterviewSimulationServiceProtocol = InterviewSimulationService()
    ) {
        self.service = service
        self.interviewSimulationService = interviewSimulationService
        self.steps = [
            .init(
                title: "Selecione cargo e senioridade",
                description: "Adicione cargo e senioridade correspondente à vaga",
                imageButton: "chevron.down",
                type: .addInfoJob
            ),
            .init(
                title: "Faça o upload do seu currículo",
                description: "Opcionalmente, envie seu currículo para gerar perguntas mais personalizadas.",
                imageButton: "doc.fill",
                type: .addCurriculum
            ),
            .init(
                title: "Adicione mais informações",
                description: "Opcionalmente, adicione a descrição ou mais informações da vaga",
                imageButton: "chevron.down",
                type: .addDescriptionJob
            )
        ]
    }

    func generateQuestions(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) {
        let normalizedJobTitle = jobTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let normalizedSeniority = seniority.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let normalizedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard isValidJobTitle(normalizedJobTitle) else {
            viewState = .error("Selecione um cargo antes de continuar.")
            return
        }

        guard isValidSeniority(normalizedSeniority) else {
            viewState = .error("Selecione uma senioridade antes de continuar.")
            return
        }

        task?.cancel()

        generatedQuestions = []
        viewState = .loading
        saveQuestionsState = .idle
        lastJobTitle = normalizedJobTitle
        lastSeniority = normalizedSeniority

        task = Task { [weak self] in
            guard let self else { return }

            do {
                let validQuestions = try await service.generateQuestions(
                    resumeURL: resumeURL,
                    jobTitle: normalizedJobTitle,
                    seniority: normalizedSeniority,
                    description: normalizedDescription
                )

                try Task.checkCancellation()

                generatedQuestions = validQuestions
                viewState = .loaded

            } catch is CancellationError {
                // Uma nova geração substituiu a anterior.
            } catch APIError.insufficientCredits {
                generatedQuestions = []
                viewState = .insufficientCredits
            } catch {
                generatedQuestions = []
                viewState = .error(error.localizedDescription)

                print(
                    "❌ Erro ao gerar perguntas:",
                    error.localizedDescription
                )
            }
        }
    }

    func retry(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) {
        generateQuestions(
            resumeURL: resumeURL,
            jobTitle: jobTitle,
            seniority: seniority,
            description: description
        )
    }

    func cancelGeneration() {
        task?.cancel()
        task = nil
    }

    func saveGeneratedQuestions() async {
        if case .saving = saveQuestionsState {
            return
        }

        if case .saved = saveQuestionsState {
            return
        }

        guard !generatedQuestions.isEmpty else {
            saveQuestionsState = .error(
                "Nenhuma pergunta foi gerada para salvar."
            )
            return
        }

        guard !lastJobTitle.isEmpty else {
            saveQuestionsState = .error(
                "O cargo da entrevista não foi encontrado."
            )
            return
        }

        guard !lastSeniority.isEmpty else {
            saveQuestionsState = .error(
                "A senioridade da entrevista não foi encontrada."
            )
            return
        }

        saveQuestionsState = .saving

        do {
            let response = try await interviewSimulationService.saveGeneratedQuestions(
                jobTitle: lastJobTitle,
                seniority: lastSeniority,
                questions: generatedQuestions
            )

            saveQuestionsState = .saved(
                response.savedCount
            )

        } catch {
            saveQuestionsState = .error(
                error.localizedDescription
            )
        }
    }

    private func isValidJobTitle(_ jobTitle: String) -> Bool {
        !jobTitle.isEmpty && jobTitle.lowercased() != "cargo"
    }

    private func isValidSeniority(_ seniority: String) -> Bool {
        !seniority.isEmpty &&
        seniority.lowercased() != "senioridade"
    }
}
