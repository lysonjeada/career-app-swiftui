//
//  GenerateQuestionsViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app
import Foundation

@Suite
struct GenerateQuestionsViewModelTests {
    @Test @MainActor
    func testGenerateQuestions_Success_SetsLoadedStateAndPopulatesQuestions() async throws {
        // Arrange
        let service = GenerateQuestionsServiceMock(isSuccess: true)
        let viewModel = GenerateQuestionsViewModel(service: service)

        // Act
        viewModel.generateQuestions(
            resumeURL: nil,
            jobTitle: "iOS Developer",
            seniority: "Pleno",
            description: "Vaga para app de carreira"
        )
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.generatedQuestions.count == 3)
        #expect(service.receivedJobTitle == "iOS Developer")
        #expect(service.receivedSeniority == "Pleno")
        #expect(service.receivedDescription == "Vaga para app de carreira")
    }

    @Test @MainActor
    func testGenerateQuestions_WhenJobTitleIsInvalid_SetsErrorWithoutCallingService() async throws {
        // Arrange
        let service = GenerateQuestionsServiceMock(isSuccess: true)
        let viewModel = GenerateQuestionsViewModel(service: service)

        // Act
        viewModel.generateQuestions(
            resumeURL: nil,
            jobTitle: "Cargo",
            seniority: "Pleno",
            description: ""
        )

        // Assert
        #expect(viewModel.viewState == .error("Selecione um cargo antes de continuar."))
        #expect(service.callCount == 0)
    }

    @Test @MainActor
    func testGenerateQuestions_WhenSeniorityIsInvalid_SetsErrorWithoutCallingService() async throws {
        // Arrange
        let service = GenerateQuestionsServiceMock(isSuccess: true)
        let viewModel = GenerateQuestionsViewModel(service: service)

        // Act
        viewModel.generateQuestions(
            resumeURL: nil,
            jobTitle: "iOS Developer",
            seniority: "Senioridade",
            description: ""
        )

        // Assert
        #expect(viewModel.viewState == .error("Selecione uma senioridade antes de continuar."))
        #expect(service.callCount == 0)
    }

    @Test @MainActor
    func testGenerateQuestions_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = GenerateQuestionsServiceMock(isSuccess: false)
        let viewModel = GenerateQuestionsViewModel(service: service)

        // Act
        viewModel.generateQuestions(
            resumeURL: nil,
            jobTitle: "iOS Developer",
            seniority: "Pleno",
            description: ""
        )

        func isErrorState() -> Bool {
            if case .error = viewModel.viewState { return true }
            return false
        }

        try await awaitCondition(until: isErrorState(), timeout: 5.0)

        // Assert
        if case let .error(message) = viewModel.viewState {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Esperava viewState .error, mas obteve \(viewModel.viewState)")
        }
        #expect(viewModel.generatedQuestions.isEmpty)
    }

    @Test @MainActor
    func testRetry_CallsGenerateQuestionsAgainWithSameParameters() async throws {
        // Arrange
        let service = GenerateQuestionsServiceMock(isSuccess: true)
        let viewModel = GenerateQuestionsViewModel(service: service)

        // Act
        viewModel.retry(
            resumeURL: nil,
            jobTitle: "iOS Developer",
            seniority: "Pleno",
            description: "Vaga para app de carreira"
        )
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(service.callCount == 1)
        #expect(service.receivedJobTitle == "iOS Developer")
        #expect(service.receivedSeniority == "Pleno")
    }
}
