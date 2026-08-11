//
//  ProgressDashboardViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct ProgressDashboardViewModelTests {
    @Test @MainActor
    func testLoad_Success_SetsLoadedStateWithDashboard() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: true)
        let viewModel = ProgressDashboardViewModel(service: service)

        // Act
        await viewModel.load()

        // Assert
        guard case let .loaded(dashboard) = viewModel.state else {
            Issue.record("Esperava state .loaded, mas obteve \(viewModel.state)")
            return
        }
        #expect(dashboard.summary.totalApplications == 12)
        #expect(dashboard.topSkills.count == 2)
        #expect(dashboard.activeCompanies.count == 2)
        #expect(dashboard.monthlyEvolution.count == 2)
        #expect(service.receivedMonths == [6])
    }

    @Test @MainActor
    func testLoad_WhenServiceFails_SetsErrorState() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: false)
        let viewModel = ProgressDashboardViewModel(service: service)

        // Act
        await viewModel.load()

        // Assert
        if case .error = viewModel.state {
            // esperado
        } else {
            Issue.record("Esperava state .error, mas obteve \(viewModel.state)")
        }
    }

    @Test @MainActor
    func testLoad_WhenAlreadyLoaded_DoesNotReloadWithoutForce() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: true)
        let viewModel = ProgressDashboardViewModel(service: service)
        await viewModel.load()

        // Act
        await viewModel.load()

        // Assert
        #expect(service.callCount == 1)
    }

    @Test @MainActor
    func testLoad_WithForceReload_RefetchesData() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: true)
        let viewModel = ProgressDashboardViewModel(service: service)
        await viewModel.load()

        // Act
        await viewModel.load(forceReload: true)

        // Assert
        #expect(service.callCount == 2)
    }

    @Test @MainActor
    func testChangePeriod_WithDifferentMonths_UpdatesSelectionAndReloads() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: true)
        let viewModel = ProgressDashboardViewModel(service: service)
        await viewModel.load()

        // Act
        await viewModel.changePeriod(to: 12)

        // Assert
        #expect(viewModel.selectedMonths == 12)
        #expect(service.receivedMonths == [6, 12])
    }

    @Test @MainActor
    func testChangePeriod_WithSameMonths_DoesNotReload() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: true)
        let viewModel = ProgressDashboardViewModel(service: service)
        await viewModel.load()

        // Act
        await viewModel.changePeriod(to: 6)

        // Assert
        #expect(service.callCount == 1)
    }

    @Test @MainActor
    func testRetry_AfterFailure_ForcesReloadAndRecovers() async throws {
        // Arrange
        let service = ProgressDashboardServiceMock(isSuccess: false)
        let viewModel = ProgressDashboardViewModel(service: service)
        await viewModel.load()

        // Act
        service.isSuccess = true
        await viewModel.retry()

        // Assert
        if case .loaded = viewModel.state {
            // esperado
        } else {
            Issue.record("Esperava state .loaded, mas obteve \(viewModel.state)")
        }
        #expect(service.callCount == 2)
    }
}
