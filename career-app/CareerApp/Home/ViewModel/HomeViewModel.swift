//
//  HomeViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation
import SwiftUI

protocol HomeViewModelCoordinatorDelegate: AnyObject {
    func goToArticleDetail(articleId: Int)
}

final class HomeViewModel: ObservableObject {
    @Published var selectedTag: String = "Todos"
    weak var coordinatorDelegate: HomeViewModelCoordinatorDelegate?
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    private(set) var articles: [Article] = []
    private(set) var jobApplications: [JobApplication] = []
    private(set) var nextJobApplications: [JobApplication] = []
    private var task: Task <Void, Never>?
    
    private var service: HomeService = HomeService()
    private var jobService: JobApplicationService = JobApplicationService()
    
    @MainActor
    func fetchHome(tag: String? = nil) {
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
                self.viewState = .loaded
            } catch {
                print("Erro ao buscar artigos:", error)
            }
        }
    }
    
    func goToArticleDetail(articleId: Int) {
        coordinatorDelegate?.goToArticleDetail(articleId: articleId)
    }
}
