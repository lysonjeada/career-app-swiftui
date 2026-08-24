//
//  ResumeFeedbackViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app
import Foundation

@Suite
struct ResumeFeedbackViewModelTests {
    @Test @MainActor
    func testSubmitResumeFeedback_Success_SetsLoadedStateAndPopulatesResponse() async throws {
        // Arrange
        let service = InterviewServiceMock(isSuccess: true)
        let viewModel = ResumeFeedbackViewModel(service: service)
        let resumeURL = URL(fileURLWithPath: "/tmp/resume.pdf")

        // Act
        viewModel.submitResumeFeedback(resumeURL: resumeURL)
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.response?.feedback == "Seu currículo está bem estruturado, mas destaque mais resultados quantificáveis.")
        #expect(viewModel.errorMessage == nil)
        #expect(service.receivedFetchResumeFeedbackURL == resumeURL)
    }

    @Test @MainActor
    func testSubmitResumeFeedback_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = InterviewServiceMock(isSuccess: false)
        let viewModel = ResumeFeedbackViewModel(service: service)
        let resumeURL = URL(fileURLWithPath: "/tmp/resume.pdf")

        // Act
        viewModel.submitResumeFeedback(resumeURL: resumeURL)
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.response == nil)
    }

    @Test @MainActor
    func testSubmitResumeFeedback_WhenBackendReturnsInsufficientCredits_SetsInsufficientCreditsState() async throws {
        // Arrange
        let service = InterviewServiceMock(isSuccess: true)
        service.shouldThrowInsufficientCredits = true
        let viewModel = ResumeFeedbackViewModel(service: service)
        let resumeURL = URL(fileURLWithPath: "/tmp/resume.pdf")

        // Act
        viewModel.submitResumeFeedback(resumeURL: resumeURL)
        try await awaitCondition(until: viewModel.viewState == .insufficientCredits, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .insufficientCredits)
        #expect(viewModel.response == nil)
    }
}
