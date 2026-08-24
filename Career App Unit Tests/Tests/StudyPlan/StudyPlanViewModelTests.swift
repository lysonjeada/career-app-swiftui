//
//  StudyPlanViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct StudyPlanViewModelTests {
    @Test @MainActor
    func testGenerateStudyPlan_Success_SetsLoadedStateAndPopulatesStudyPlan() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)

        // Assert
        #expect(viewModel.state == .loaded)
        #expect(viewModel.studyPlan?.title == "Plano de estudos para iOS Developer Pleno")
        #expect(viewModel.totalTopicsCount == 2)
        #expect(viewModel.completedTopicsCount == 0)
        #expect(service.receivedJobTitle == "iOS Developer")
        #expect(service.receivedSeniority == "Pleno")
    }

    @Test @MainActor
    func testGenerateStudyPlan_WithEmptyJobTitle_SetsErrorState() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.generateStudyPlan(jobTitle: "  ", seniority: "Pleno", description: "", resumeURL: nil)

        // Assert
        #expect(viewModel.state == .error("Informe o cargo desejado."))
        #expect(viewModel.studyPlan == nil)
        #expect(service.callCount == 0)
    }

    @Test @MainActor
    func testGenerateStudyPlan_WithPlaceholderSeniority_SetsErrorState() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Senioridade", description: "", resumeURL: nil)

        // Assert
        #expect(viewModel.state == .error("Selecione a senioridade."))
        #expect(service.callCount == 0)
    }

    @Test @MainActor
    func testGenerateStudyPlan_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: false)
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)

        // Assert
        if case .error = viewModel.state {
            // esperado
        } else {
            Issue.record("Esperava state .error, mas obteve \(viewModel.state)")
        }
        #expect(viewModel.studyPlan == nil)
    }

    @Test @MainActor
    func testGenerateStudyPlan_WhenBackendReturnsInsufficientCredits_SetsInsufficientCreditsState() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        service.shouldThrowInsufficientCredits = true
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)

        // Assert
        #expect(viewModel.state == .insufficientCredits)
        #expect(viewModel.studyPlan == nil)
    }

    @Test @MainActor
    func testRetry_WithoutPreviousRequest_SetsIdleState() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)

        // Act
        await viewModel.retry()

        // Assert
        #expect(viewModel.state == .idle)
        #expect(service.callCount == 0)
    }

    @Test @MainActor
    func testRetry_AfterFailure_RecoversWithSameParameters() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: false)
        let viewModel = StudyPlanViewModel(service: service)
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)

        // Act
        service.isSuccess = true
        await viewModel.retry()

        // Assert
        #expect(viewModel.state == .loaded)
        #expect(service.callCount == 2)
        #expect(service.receivedJobTitle == "iOS Developer")
        #expect(service.receivedSeniority == "Pleno")
    }

    @Test @MainActor
    func testToggleTopic_TogglesCompletionAndUpdatesProgress() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)
        let firstTopicId = try #require(viewModel.studyPlan?.topics.first?.id)

        // Act
        viewModel.toggleTopic(id: firstTopicId)

        // Assert
        #expect(viewModel.studyPlan?.topics.first?.isCompleted == true)
        #expect(viewModel.completedTopicsCount == 1)
        #expect(viewModel.progress == 0.5)
    }

    @Test @MainActor
    func testRestart_ResetsStateAndStudyPlan() async throws {
        // Arrange
        let service = StudyPlanServiceMock(isSuccess: true)
        let viewModel = StudyPlanViewModel(service: service)
        await viewModel.generateStudyPlan(jobTitle: "iOS Developer", seniority: "Pleno", description: "", resumeURL: nil)

        // Act
        viewModel.restart()

        // Assert
        #expect(viewModel.state == .idle)
        #expect(viewModel.studyPlan == nil)

        // retry após restart não deve reutilizar a última requisição
        await viewModel.retry()
        #expect(viewModel.state == .idle)
        #expect(service.callCount == 1)
    }
}
