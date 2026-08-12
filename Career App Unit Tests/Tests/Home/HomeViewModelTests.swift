//
//  HomeViewModelTests.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

import Testing
@testable import career_app

@Suite
struct HomeViewModelTests {
    @Test @MainActor
    func testFetchHome_PopulatesDataAndSetsViewStateToLoaded() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: true)
        let jobService = JobApplicationServiceMock(isSuccess: true)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        // Act
        viewModel.fetchHome()
        
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.articles.count == 1)
        #expect(viewModel.articles.first?.title == "Test Article")
        #expect(viewModel.jobApplications.count == 1)
        #expect(viewModel.githubJobListing.count == 1)
        #expect(viewModel.availableJobs.count == 3)
    }

    @Test @MainActor
    func testFetchHome_WhenServicesFail_SetsViewStateToErrorAndKeepsDataEmpty() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: false)
        let jobService = JobApplicationServiceMock(isSuccess: false)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        // Act
        viewModel.fetchHome()
        
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.jobApplications.isEmpty)
        #expect(viewModel.nextJobApplications.isEmpty)
        #expect(viewModel.githubJobListing.isEmpty)
        #expect(viewModel.availableJobs.isEmpty)
    }

    @Test @MainActor
    func testFetchHome_WhenOnlyArticlesServiceFails_KeepsViewStateLoadedWithArticlesEmpty() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: false)
        let jobService = JobApplicationServiceMock(isSuccess: true)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        // Act
        viewModel.fetchHome()

        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.jobApplications.count == 1)
        #expect(viewModel.nextJobApplications.count == 1)
        #expect(viewModel.githubJobListing.count == 1)
        #expect(viewModel.availableJobs.count == 3)
    }

    @Test @MainActor
    func testFetchHome_WhenOnlyJobServiceFails_KeepsViewStateLoadedWithArticlesPopulated() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: true)
        let jobService = JobApplicationServiceMock(isSuccess: false)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        // Act
        viewModel.fetchHome()

        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.articles.count == 1)
        #expect(viewModel.jobApplications.isEmpty)
        #expect(viewModel.nextJobApplications.isEmpty)
        #expect(viewModel.githubJobListing.isEmpty)
        #expect(viewModel.availableJobs.isEmpty)
    }

    @Test @MainActor
    func testFetchHome_ForwardsTagAndRepositoryToServices() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: true)
        let jobService = JobApplicationServiceMock(isSuccess: true)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        // Act
        viewModel.fetchHome(tag: "swift", repository: "swift-jobs")

        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(homeService.receivedTag == "swift")
        #expect(jobService.receivedRepository == "swift-jobs")
    }

    @Test @MainActor
    func testTryAgain_RefetchesAndRecoversFromError() async throws {
        // Arrange
        let homeService = HomeServiceMock(isSuccess: false)
        let jobService = JobApplicationServiceMock(isSuccess: false)
        let viewModel = HomeViewModel(service: homeService, jobService: jobService)

        viewModel.fetchHome()
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)
        #expect(viewModel.viewState == .error)

        // Act
        homeService.isSuccess = true
        jobService.isSuccess = true
        viewModel.tryAgain()

        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.articles.count == 1)
        #expect(viewModel.jobApplications.count == 1)
    }
}
