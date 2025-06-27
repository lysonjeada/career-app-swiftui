//
//  JobApplicationTrackerListViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/06/25.
//

import Foundation

struct InterviewResponse: Codable {
    let id: UUID
    let company_name: String
    let job_seniority: String
    let job_title: String
    let last_interview_date: String?
    let next_interview_date: String?
    let location: String?
    let notes: String?
    let skills: [String]?
    let created_at: String
    let updated_at: String
}


class JobApplicationTrackerListViewModel: ObservableObject {
    private let service = JobApplicationService()
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    @Published var jobApplications: [JobApplication] = []
    private var task: Task<Void, Never>?
    
    func fetchJobApplications() {
            viewState = .loading

            task = Task {
                do {
                    let interviews = try await service.fetchInterviews()
                    let apps = interviews.map {
                        JobApplication(
                            id: $0.id,
                            company: $0.company_name,
                            level: $0.job_seniority, // ajuste conforme necessário
                            role: $0.job_title,  // ajuste conforme necessário
                            lastInterview: $0.last_interview_date,
                            nextInterview: $0.next_interview_date,
                            technicalSkills: $0.skills ?? [],
                            jobTitle: $0.job_title
                        )
                    }

                    await MainActor.run {
                        self.jobApplications = apps
                        self.viewState = .loaded
                    }
                } catch {
                    print("❌ Erro ao buscar entrevistas: \(error.localizedDescription)")
                }
            }
        }

}
