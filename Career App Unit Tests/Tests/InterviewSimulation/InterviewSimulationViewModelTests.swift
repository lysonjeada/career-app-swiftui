//
//  InterviewSimulationViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct InterviewSimulationViewModelTests {
    @Test @MainActor
    func testStartSimulation_Success_PopulatesQuestionsAndSetsAnsweringState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Assert
        #expect(viewModel.state == .answering)
        #expect(viewModel.questions.count == 3)
        #expect(viewModel.currentIndex == 0)
        #expect(service.receivedJobTitle == "iOS Developer")
        #expect(service.receivedSeniority == "Pleno")
    }

    @Test @MainActor
    func testStartSimulation_WithEmptyJobTitle_SetsErrorMessageAndKeepsIdle() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act
        await viewModel.startSimulation(jobTitle: "  ", seniority: "Pleno", description: "")

        // Assert
        #expect(viewModel.state == .idle)
        #expect(viewModel.errorMessage == "Informe o cargo da entrevista.")
        #expect(viewModel.questions.isEmpty)
    }

    @Test @MainActor
    func testStartSimulation_WhenBackendReturnsInsufficientCredits_SetsInsufficientCreditsState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        service.shouldThrowInsufficientCredits = true
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Assert
        #expect(viewModel.state == .insufficientCredits)
        #expect(viewModel.questions.isEmpty)
    }

    @Test @MainActor
    func testStartSimulation_WithPlaceholderSeniority_SetsErrorMessageAndKeepsIdle() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Senioridade", description: "")

        // Assert
        #expect(viewModel.state == .idle)
        #expect(viewModel.errorMessage == "Selecione a senioridade.")
    }

    @Test @MainActor
    func testStartSimulation_WhenServiceFails_SetsErrorMessageAndStateIdle() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: false)
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Assert
        #expect(viewModel.state == .idle)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.questions.isEmpty)
    }

    @Test @MainActor
    func testSubmitTextAnswer_AdvancesToNextQuestion() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")
        viewModel.currentAnswer = "Minha resposta para a primeira pergunta."

        // Act
        await viewModel.submitTextAnswer()

        // Assert
        #expect(viewModel.state == .answering)
        #expect(viewModel.currentIndex == 1)
        #expect(viewModel.answers.count == 1)
        #expect(viewModel.currentAnswer.isEmpty)
    }

    @Test @MainActor
    func testSubmitTextAnswer_OnLastQuestion_CompletesEvaluation() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Act — responde as 3 perguntas geradas pelo mock
        for _ in 0..<3 {
            viewModel.currentAnswer = "Resposta de teste."
            await viewModel.submitTextAnswer()
        }

        // Assert
        #expect(viewModel.state == .completed)
        #expect(viewModel.answers.count == 3)
        #expect(viewModel.evaluation?.overall == 8)
        #expect(viewModel.evaluation?.summary == "Respostas claras e com bom domínio técnico.")
    }

    @Test @MainActor
    func testSubmitTextAnswer_WhenEvaluationServiceFails_SetsEvaluationFailedState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Act
        for index in 0..<3 {
            if index == 2 {
                service.isSuccess = false
            }
            viewModel.currentAnswer = "Resposta de teste."
            await viewModel.submitTextAnswer()
        }

        // Assert
        #expect(viewModel.state == .evaluationFailed)
        #expect(viewModel.evaluation == nil)
        #expect(viewModel.errorMessage != nil)
    }

    @Test @MainActor
    func testSubmitTextAnswer_WithEmptyAnswer_KeepsAnsweringStateWithError() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")
        viewModel.currentAnswer = "   "

        // Act
        await viewModel.submitTextAnswer()

        // Assert
        #expect(viewModel.state == .answering)
        #expect(viewModel.errorMessage == "Digite ou grave uma resposta.")
        #expect(viewModel.answers.isEmpty)
        #expect(viewModel.currentIndex == 0)
    }

    @Test @MainActor
    func testSaveGeneratedQuestions_Success_SetsSavedState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")

        // Act
        await viewModel.saveGeneratedQuestions()

        // Assert
        #expect(viewModel.saveQuestionsState == .saved(3))
    }

    @Test @MainActor
    func testSaveGeneratedQuestions_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)
        await viewModel.startSimulation(jobTitle: "iOS Developer", seniority: "Pleno", description: "")
        service.isSuccess = false

        // Act
        await viewModel.saveGeneratedQuestions()

        // Assert
        if case .error = viewModel.saveQuestionsState {
            // esperado
        } else {
            Issue.record("Esperava saveQuestionsState .error, mas obteve \(viewModel.saveQuestionsState)")
        }
    }

    @Test @MainActor
    func testSaveGeneratedQuestions_WithoutQuestions_SetsErrorState() async throws {
        // Arrange
        let service = InterviewSimulationServiceMock(isSuccess: true)
        let viewModel = InterviewSimulationViewModel(service: service)

        // Act — nenhuma simulação foi iniciada, então não há perguntas geradas
        await viewModel.saveGeneratedQuestions()

        // Assert
        #expect(viewModel.saveQuestionsState == .error("Nenhuma pergunta foi gerada para salvar."))
    }
}
