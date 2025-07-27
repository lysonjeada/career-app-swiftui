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
            // Inicializa com dados vazios para garantir que, se falhar, não teremos lixo
            self.articles = []
            self.jobApplications = []
            self.nextJobApplications = []
            self.githubJobListing = []
            self.availableJobs = []

            // Fetch Articles
            do {
                self.articles = try await service.fetchArticles(tag: tag)
            } catch {
                print("Erro ao buscar artigos: \(error.localizedDescription)")
                // Opcional: registrar o erro, mostrar uma mensagem específica para o usuário
            }

            // Fetch Job Applications (Interviews)
            do {
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
            } catch {
                print("Erro ao buscar candidaturas de emprego: \(error.localizedDescription)")
            }

            // Fetch Next Job Applications (Next Interviews)
            do {
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
            } catch {
                print("Erro ao buscar próximas entrevistas: \(error.localizedDescription)")
            }

            // Fetch GitHub Job Listing
            do {
                if let repository {
                    self.githubJobListing = try await jobService.fetchJobListings(repository: repository)
                } else {
                    self.githubJobListing = try await jobService.fetchJobListings(repository: nil)
                }
            } catch {
                print("Erro ao buscar vagas do GitHub: \(error.localizedDescription)")
            }

            // Fetch Available Repositories
            do {
                self.availableJobs = try await jobService.fetchAvailableRepositories()
            } catch {
                print("Erro ao buscar repositórios disponíveis: \(error.localizedDescription)")
            }

            // Após todas as tentativas, verifique se há *algum* dado carregado.
            // Se todas falharem, o viewState pode ser .error, caso contrário, .loaded.
            if articles.isEmpty && jobApplications.isEmpty && nextJobApplications.isEmpty && githubJobListing.isEmpty && availableJobs.isEmpty {
                self.viewState = .error
            } else {
                self.viewState = .loaded
            }
        }
    }
    
    func tryAgain() {
        fetchHome()
    }
    
    func goToDevTo() {
        if let url = URL(string: "https://dev.to/") {
            UIApplication.shared.open(url)
        }
    }
}
