//
//  Home.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

@testable import career_app
import Foundation

final class HomeServiceMock: HomeServiceProtocol {
    let isSuccess: Bool
    
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }
    
    func fetchArticles(tag: String?) async throws -> [Article] {
        guard isSuccess else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONLoader.load("article-list-response")
    }
}

final class JobApplicationServiceMock: JobApplicationServiceProtocol {
    let isSuccess: Bool
    
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
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
        // no-op para testes
    }
    
    func updateInterview(interviewId: String, request: InterviewRequest) async throws {
        // no-op para testes
    }
    
    func deleteInterview(interviewId: String) async throws {
        // no-op para testes
    }
    
    func fetchInterviews() async throws -> [InterviewResponse] {
        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
        
        return try JSONLoader.load("interview-list-response")
    }
    
    func fetchNextInterviews() async throws -> [InterviewResponse] {
        guard isSuccess else {
            throw URLError(.notConnectedToInternet)
        }
        
        return try JSONLoader.load("interview-list-response")
    }
    
    func fetchJobListings(repository: String?) async throws -> [GitHubJobListing] {
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

