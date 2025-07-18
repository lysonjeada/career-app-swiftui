//
//  HomeViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var selectedTag: String = "Todos"
    
    enum State: Equatable {
        case loading
        case loaded
        case error
    }
    
    @Published private(set) var viewState: State = .loading
    @StateObject var coordinator = Coordinator()
    
    private(set) var articles: [Article] = []
    private(set) var jobApplications: [JobApplication] = []
    private(set) var nextJobApplications: [JobApplication] = []
    private(set) var githubJobListing: [GitHubJobListing] = []
    private(set) var availableJobs: [String] = []
    private var task: Task <Void, Never>?
    
    private let service: HomeServiceProtocol
    private let jobService: JobApplicationServiceProtocol

    init(service: HomeServiceProtocol = HomeService(), jobService: JobApplicationServiceProtocol = JobApplicationService()) {
        self.service = service
        self.jobService = jobService
    }
    
    @MainActor
    func fetchHome(tag: String? = nil, repository: String? = nil) {
        viewState = .loading
        task = Task {
            do {
                self.articles = try await service.fetchArticles(tag: tag)
                self.jobApplications = try await jobService
                    .fetchInterviews()
                    .map { interview in
                        JobApplication(
                            id: interview.id,
                            company: interview.company_name,
                            level: interview.job_seniority,
                            role: interview.job_title,
                            lastInterview: interview.last_interview_date,
                            nextInterview: interview.next_interview_date,
                            technicalSkills: interview.skills ?? []
                        )
                    }
                self.nextJobApplications = try await jobService.fetchNextInterviews()
                    .map { interview in
                        JobApplication(
                            id: interview.id,
                            company: interview.company_name,
                            level: interview.job_seniority,
                            role: interview.job_title,
                            lastInterview: interview.last_interview_date,
                            nextInterview: interview.next_interview_date,
                            technicalSkills: interview.skills ?? []
                        )
                    }
                if let repository {
                    self.githubJobListing = try await jobService.fetchJobListings(repository: repository)
                } else {
                    self.githubJobListing = try await jobService.fetchJobListings(repository: nil)
                }
                self.availableJobs = try await jobService.fetchAvailableRepositories()
                self.viewState = .loaded
            } catch {
                self.viewState = .error
            }
        }
    }
    
    func goToDevTo() {
        if let url = URL(string: "https://dev.to/") {
            UIApplication.shared.open(url)
        }
    }
}
