//
//  Home.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

@testable import career_app
import Foundation

final class HomeServiceMock: HomeServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedTag: String?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func fetchArticles(tag: String?) async throws -> [Article] {
        receivedTag = tag

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("article-list-response")
    }
}

final class JobApplicationServiceMock: JobApplicationServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedRepository: String?

    private(set) var receivedAddInterviewCompanyName: String?
    private(set) var receivedAddInterviewJobTitle: String?
    private(set) var receivedAddInterviewJobSeniority: String?
    private(set) var receivedAddInterviewLastInterview: String?
    private(set) var receivedAddInterviewNextInterview: String?
    private(set) var receivedAddInterviewLocation: String?
    private(set) var receivedAddInterviewNotes: String?
    private(set) var receivedAddInterviewSkills: [String]?

    private(set) var receivedUpdateInterviewId: String?
    private(set) var receivedUpdateInterviewRequest: InterviewRequest?

    private(set) var receivedDeleteInterviewId: String?

    private let interviewsFixtureName: String

    init(isSuccess: Bool, interviewsFixtureName: String = "interview-list-response") {
        self.isSuccess = isSuccess
        self.interviewsFixtureName = interviewsFixtureName
    }

    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String,
        skills: [String]
    ) async throws {
        receivedAddInterviewCompanyName = companyName
        receivedAddInterviewJobTitle = jobTitle
        receivedAddInterviewJobSeniority = jobSeniority
        receivedAddInterviewLastInterview = lastInterview
        receivedAddInterviewNextInterview = nextInterview
        receivedAddInterviewLocation = location
        receivedAddInterviewNotes = notes
        receivedAddInterviewSkills = skills

        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
    }

    func updateInterview(interviewId: String, request: InterviewRequest) async throws {
        receivedUpdateInterviewId = interviewId
        receivedUpdateInterviewRequest = request

        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
    }

    func deleteInterview(interviewId: String) async throws {
        receivedDeleteInterviewId = interviewId

        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
    }
    
    func fetchInterviews() async throws -> [InterviewResponse] {
        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }

        return try JSONLoader.load(interviewsFixtureName)
    }

    func fetchNextInterviews() async throws -> [InterviewResponse] {
        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }

        return try JSONLoader.load(interviewsFixtureName)
    }
    
    func fetchJobListings(repository: String?) async throws -> [GitHubJobListing] {
        receivedRepository = repository

        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }

        return try JSONLoader.load("github-job-list-response")
    }
    
    func fetchAvailableRepositories() async throws -> [String] {
        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
        
        return ["swift-jobs", "ios-architecture", "career-app"]
    }
}

