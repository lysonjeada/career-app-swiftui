//
//  HomeViewModelTests.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

import XCTest
@testable import career_app

final class HomeViewModelTests: XCTestCase {
    private var viewModel: HomeViewModel!
    private var homeServiceMock: HomeServiceMock!
    private var jobServiceMock: JobApplicationServiceMock!

    override func setUp() {
        super.setUp()
        homeServiceMock = HomeServiceMock(isSuccess: true)
        jobServiceMock = JobApplicationServiceMock(isSuccess: true)
        viewModel = HomeViewModel(service: homeServiceMock, jobService: jobServiceMock)
    }
    
    @MainActor
    func testFetchHome_SetsViewStateToLoadedAndPopulatesData() async throws {
        viewModel.fetchHome()

        await wait(until: self.viewModel.viewState == .loaded)

        XCTAssertEqual(viewModel.articles.count, 1)
        XCTAssertEqual(viewModel.articles.first?.title, "Test Article")
        XCTAssertEqual(viewModel.jobApplications.count, 1)
        XCTAssertEqual(viewModel.githubJobListing.count, 1)
        XCTAssertEqual(viewModel.availableJobs.count, 3)
    }
    
    @MainActor
    func testFetchHome_WhenServiceFails_SetsViewStateToError() async throws {
        let failingHomeService = HomeServiceMock(isSuccess: false)
        let failingJobService = JobApplicationServiceMock(isSuccess: false)
        viewModel = HomeViewModel(service: failingHomeService, jobService: failingJobService)

        viewModel.fetchHome()

        await wait(until: self.viewModel.viewState == .error)

        XCTAssertEqual(viewModel.viewState, .error)
        XCTAssertTrue(viewModel.articles.isEmpty)
        XCTAssertTrue(viewModel.jobApplications.isEmpty)
        XCTAssertTrue(viewModel.nextJobApplications.isEmpty)
        XCTAssertTrue(viewModel.githubJobListing.isEmpty)
        XCTAssertTrue(viewModel.availableJobs.isEmpty)
    }

}

extension XCTestCase {
    func wait(
        until condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval = 1.0,
        interval: TimeInterval = 0.01,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let startTime = Date()
        while !condition() && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        XCTAssertTrue(condition(), "Condition was not met in time", file: file, line: line)
    }
}
