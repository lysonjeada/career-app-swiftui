//
//  JobApplicationTrackerListViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app
import Foundation

@Suite
struct JobApplicationTrackerListViewModelTests {
    @Test @MainActor
    func testFetchJobApplications_Success_SetsLoadedStateAndPopulatesApplications() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: true, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        viewModel.fetchJobApplications()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.jobApplications.count == 1)
        #expect(viewModel.jobApplications.first?.company == "Empresa Teste")
        #expect(viewModel.jobApplications.first?.role == "iOS Developer")
        #expect(viewModel.jobApplications.first?.level == "Pleno")
        #expect(viewModel.jobApplications.first?.lastInterview == "09/03")
        #expect(viewModel.jobApplications.first?.nextInterview == "19/03")
        #expect(viewModel.jobApplications.first?.technicalSkills == ["Swift", "SwiftUI"])
        #expect(viewModel.showSnackBar == false)
    }

    @Test @MainActor
    func testFetchJobApplications_WhenServiceFails_ShowsErrorSnackBar() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: false, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        viewModel.fetchJobApplications()
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.jobApplications.isEmpty)
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Falha ao carregar candidaturas.")
    }

    @Test @MainActor
    func testAddInterview_Success_CallsServiceAndRefetchesApplications() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: true, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        let success = await viewModel.addInterview(
            companyName: "Empresa Nova",
            jobTitle: "iOS Developer",
            jobSeniority: "Pleno",
            lastInterview: "10/03/2026",
            nextInterview: "20/03/2026",
            location: "Remoto",
            notes: "Observações",
            skills: ["Swift"]
        )
        try await awaitCondition(until: !viewModel.jobApplications.isEmpty, timeout: 5.0)

        // Assert
        #expect(success == true)
        #expect(service.receivedAddInterviewCompanyName == "Empresa Nova")
        #expect(service.receivedAddInterviewJobTitle == "iOS Developer")
        #expect(service.receivedAddInterviewSkills == ["Swift"])
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Candidatura adicionada com sucesso!")
    }

    @Test @MainActor
    func testAddInterview_WhenServiceFails_ShowsErrorSnackBar() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: false, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        let success = await viewModel.addInterview(
            companyName: "Empresa Nova",
            jobTitle: "iOS Developer",
            jobSeniority: "Pleno",
            lastInterview: "10/03/2026",
            nextInterview: "20/03/2026",
            location: "Remoto",
            notes: "Observações",
            skills: ["Swift"]
        )

        // Assert
        #expect(success == false)
        #expect(viewModel.jobApplications.isEmpty)
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Não foi possível adicionar a candidatura.")
    }

    @Test @MainActor
    func testDeleteInterview_Success_CallsServiceAndRefetchesApplications() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: true, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        viewModel.deleteInterview(interviewId: "interview-1")
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)
        try await awaitCondition(until: !viewModel.jobApplications.isEmpty, timeout: 5.0)

        // Assert
        #expect(service.receivedDeleteInterviewId == "interview-1")
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Candidatura excluída com sucesso!")
    }

    @Test @MainActor
    func testDeleteInterview_WhenServiceFails_ShowsErrorSnackBar() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: false, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        viewModel.deleteInterview(interviewId: "interview-1")
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(service.receivedDeleteInterviewId == "interview-1")
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Não foi possível excluir a candidatura.")
    }

    @Test @MainActor
    func testEditJob_Success_BuildsRequestWithFormattedDatesAndCallsService() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: true, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        let success = await viewModel.editJob(
            id: "interview-1",
            company: "Nova Empresa",
            role: "Backend Developer",
            level: "Sênior",
            lastInterview: "10/03/2026",
            nextInterview: "20/03/2026",
            technicalSkills: ["Swift"]
        )

        // Assert
        #expect(success == true)
        #expect(service.receivedUpdateInterviewId == "interview-1")
        #expect(service.receivedUpdateInterviewRequest?.company_name == "Nova Empresa")
        #expect(service.receivedUpdateInterviewRequest?.job_title == "Backend Developer")
        #expect(service.receivedUpdateInterviewRequest?.job_seniority == "Sênior")
        #expect(service.receivedUpdateInterviewRequest?.last_interview_date == "2026-03-10")
        #expect(service.receivedUpdateInterviewRequest?.next_interview_date == "2026-03-20")
        #expect(service.receivedUpdateInterviewRequest?.skills == ["Swift"])
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Candidatura atualizada com sucesso!")
    }

    @Test @MainActor
    func testEditJob_WhenServiceFails_ShowsErrorSnackBar() async throws {
        // Arrange
        let service = JobApplicationServiceMock(isSuccess: false, interviewsFixtureName: "interview-tracker-list-response")
        let viewModel = JobApplicationTrackerListViewModel(service: service)

        // Act
        let success = await viewModel.editJob(
            id: "interview-1",
            company: "Nova Empresa",
            role: "Backend Developer",
            level: "Sênior",
            lastInterview: "10/03/2026",
            nextInterview: "20/03/2026",
            technicalSkills: ["Swift"]
        )

        // Assert
        #expect(success == false)
        #expect(viewModel.showSnackBar == true)
        #expect(viewModel.snackBarMessage == "Não foi possível atualizar a candidatura.")
    }
}
