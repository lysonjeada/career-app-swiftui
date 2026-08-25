//
//  HomeViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel:
    ObservableObject {

    @Published
    var selectedTag: String = "Todos"

    enum State: Equatable {
        case loading
        case loaded
        case error
    }

    @Published private(set)
    var viewState: State = .loading

    @Published private(set)
    var articles: [Article] = []

    @Published private(set)
    var jobApplications:
        [JobApplication] = []

    @Published private(set)
    var nextJobApplications:
        [JobApplication] = []

    @Published private(set)
    var githubJobListing:
        [GitHubJobListing] = []

    @Published private(set)
    var availableJobs:
        [String] = []

    private var task:
        Task<Void, Never>?

    private let service:
        HomeServiceProtocol

    private let jobService:
        JobApplicationServiceProtocol
    
    @Published private(set)
    var videos: [TechVideo] = []

    private let videoService:
        VideoServiceProtocol =
        VideoService()

    init(
        service: HomeServiceProtocol =
            HomeService(),
        jobService:
            JobApplicationServiceProtocol =
            JobApplicationService()
    ) {
        self.service = service
        self.jobService = jobService
    }

    func fetchHome(
        tag: String? = nil,
        repository: String? = nil
    ) {
        print(
            """
            🏠 fetchHome iniciado

            🔐 Autenticado:
            \(AuthSession.shared.isAuthenticated)

            👤 User ID:
            \(AuthSession.shared.userId ?? "SEM USER ID")

            🔑 Token presente:
            \(AuthSession.shared.accessToken != nil)
            """
        )

        viewState = .loading

        task?.cancel()

        task = Task {
            articles = []
            jobApplications = []
            nextJobApplications = []
            githubJobListing = []
            availableJobs = []

            // As cinco chamadas abaixo são independentes entre si (nenhuma
            // usa o resultado da outra), então disparamos todas de uma vez
            // com `async let` em vez de aguardá-las uma a uma — o tempo
            // total passa a ser o da chamada mais lenta, não a soma de
            // todas.
            async let articlesResult =
                service.fetchArticles(tag: tag)

            async let interviewsResult =
                jobService.fetchInterviews()

            async let nextInterviewsResult =
                jobService.fetchNextInterviews()

            async let videosResult =
                videoService.fetchApprovedVideos(
                    page: 1,
                    pageSize: 10
                )

            async let availableJobsResult =
                jobService.fetchAvailableRepositories()

            // MARK: - Articles

            do {
                print(
                    "📰 Buscando artigos..."
                )

                articles =
                    try await articlesResult

                print(
                    """
                    ✅ Artigos carregados:
                    \(articles.count)
                    """
                )

            } catch {
                print(
                    """
                    ❌ Erro ao buscar artigos:
                    \(error)
                    """
                )
            }

            // MARK: - All interviews

            do {
                print(
                    "💼 Buscando candidaturas..."
                )

                let interviews =
                    try await interviewsResult

                print(
                    """
                    ✅ Entrevistas recebidas:
                    \(interviews.count)
                    """
                )

                for interview in interviews {
                    print(
                        """
                        💼 Interview:
                        Empresa: \(interview.company_name)
                        Próxima: \(interview.next_interview_date ?? "NIL")
                        """
                    )
                }
                
                

                jobApplications =
                    interviews.map {
                        interview in

                        JobApplication(
                            id:
                                interview.id,
                            company:
                                interview.company_name,
                            level:
                                interview.job_seniority,
                            role:
                                interview.job_title,
                            lastInterview:
                                interview
                                    .last_interview_date?
                                    .toDate()?
                                    .toDayMonthString(),
                            nextInterview:
                                interview
                                    .next_interview_date?
                                    .toDate()?
                                    .toDayMonthString(),
                            technicalSkills:
                                interview.skills ?? []
                        )
                    }

                print(
                    """
                    ✅ jobApplications mapeadas:
                    \(jobApplications.count)
                    """
                )

            } catch {
                print(
                    """
                    ❌ Erro ao buscar candidaturas:
                    \(error)

                    \(error.localizedDescription)
                    """
                )
            }

            // MARK: - Next Interviews

            do {
                print(
                    """
                    📅 ==============================
                    📅 BUSCANDO PRÓXIMAS ENTREVISTAS
                    📅 ==============================
                    """
                )

                let nextInterviews =
                    try await nextInterviewsResult

                print(
                    """
                    ✅ Endpoint /interviews/next/
                    retornou \(nextInterviews.count)
                    entrevistas.
                    """
                )

                for interview
                    in nextInterviews {

                    print(
                        """
                        📌 Próxima entrevista

                        Empresa:
                        \(interview.company_name)

                        Cargo:
                        \(interview.job_title)

                        Data bruta:
                        \(interview.next_interview_date ?? "NIL")
                        """
                    )
                }

                nextJobApplications =
                    nextInterviews.map {
                        interview in

                        let convertedDate =
                            interview
                                .next_interview_date?
                                .toDate()?
                                .toDayMonthString()

                        print(
                            """
                            🔄 Mapeando próxima entrevista

                            Empresa:
                            \(interview.company_name)

                            Data backend:
                            \(interview.next_interview_date ?? "NIL")

                            Data convertida:
                            \(convertedDate ?? "NIL")
                            """
                        )

                        return JobApplication(
                            id:
                                interview.id,
                            company:
                                interview.company_name,
                            level:
                                interview.job_seniority,
                            role:
                                interview.job_title,
                            lastInterview:
                                interview
                                    .last_interview_date?
                                    .toDate()?
                                    .toDayMonthString(),
                            nextInterview:
                                convertedDate,
                            technicalSkills:
                                interview.skills ?? []
                        )
                    }

                print(
                    """
                    🎯 RESULTADO FINAL

                    nextJobApplications.count:
                    \(nextJobApplications.count)
                    """
                )

            } catch {
                print(
                    """
                    ❌ ERRO NO /interviews/next/

                    \(error)

                    \(error.localizedDescription)
                    """
                )
            }

            // MARK: - Vídeos

            do {
                let response =
                    try await videosResult

                videos =
                    response.items

            } catch {
                print(
                    """
                    ❌ Erro ao carregar vídeos da Home:
                    \(error)
                    """
                )
            }

            // MARK: - Repositories

            do {
                availableJobs =
                    try await availableJobsResult

            } catch {
                print(
                    """
                    ❌ Erro ao buscar repositórios:
                    \(error.localizedDescription)
                    """
                )
            }

            // MARK: - Final State

            print(
                """
                🏁 HOME FINALIZADA

                Artigos:
                \(articles.count)

                Candidaturas:
                \(jobApplications.count)

                Próximas entrevistas:
                \(nextJobApplications.count)

                Vagas GitHub:
                \(githubJobListing.count)

                Repositórios:
                \(availableJobs.count)
                """
            )

            if articles.isEmpty &&
                jobApplications.isEmpty &&
                nextJobApplications.isEmpty &&
                githubJobListing.isEmpty &&
                availableJobs.isEmpty {

                viewState = .error

            } else {
                viewState = .loaded
            }
        }
    }

    func tryAgain() {
        fetchHome()
    }

    func goToDevTo() {
        guard let url = URL(
            string: "https://dev.to/"
        ) else {
            return
        }

        UIApplication.shared.open(
            url
        )
    }
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()

        formatter.calendar = Calendar(
            identifier: .gregorian
        )

        formatter.locale = Locale(
            identifier: "en_US_POSIX"
        )

        formatter.timeZone = TimeZone(
            secondsFromGMT: 0
        )

        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false

        let date = formatter.date(
            from: self
        )

        print(
            """
            📅 String → Date

            String:
            \(self)

            Date:
            \(date?.description ?? "NIL")
            """
        )

        return date
    }
}
