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
    
    @MainActor
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
                        technicalSkills: $0.skills ?? []
                    )
                }
                
                setApplications(apps: apps)
                self.viewState = .loaded
            } catch {
                print("❌ Erro ao buscar entrevistas: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func deleteInterview(interviewId: String) {
        viewState = .loading
        task = Task { [weak self] in
            do {
                try await self?.service.deleteInterview(interviewId: interviewId)
                self?.fetchJobApplications()
            } catch {
                print("❌ Erro ao atualizar entrevista: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String = "",
        skills: [String]
    ) {
        viewState = .loading
        task = Task { [weak self] in
            do {
                guard let self else { return }
                
                try await self.service.addInterview(
                    companyName: companyName,
                    jobTitle: jobTitle,
                    jobSeniority: jobSeniority,
                    lastInterview: lastInterview,
                    nextInterview: nextInterview,
                    location: location,
                    notes: notes,
                    skills: skills
                )
                self.fetchJobApplications()
//                self.viewState = .loading
//                let interviews = try await self.service.fetchInterviews()
//                let apps = interviews.map {
//                    JobApplication(
//                        id: $0.id,
//                        company: $0.company_name,
//                        level: $0.job_seniority, // ajuste conforme necessário
//                        role: $0.job_title,  // ajuste conforme necessário
//                        lastInterview: $0.last_interview_date,
//                        nextInterview: $0.next_interview_date,
//                        technicalSkills: $0.skills ?? []
//                    )
//                }
//                
//                self.jobApplications = apps
            } catch {
                print("❌ Erro ao adicionar entrevista: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func editJob(
        id: UUID,
        company: String,
        role: String,
        level: String,
        lastInterview: String?,
        nextInterview: String?,
        technicalSkills: [String]
    ) {
        viewState = .loading

        task = Task { [weak self] in
            do {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"

                let request = InterviewRequest(
                    company_name: company,
                    job_title: role,
                    job_seniority: level,
                    last_interview_date: self!.formatDate(lastInterview ?? ""),
                    next_interview_date: self!.formatDate(nextInterview ?? ""),
                    location: nil,
                    notes: nil,
                    skills: technicalSkills
                )

                try await self?.service.updateInterview(interviewId: id.uuidString, request: request)
                self?.fetchJobApplications()
                self?.viewState = .loaded
            } catch {
                print("❌ Erro ao atualizar entrevista: \(error.localizedDescription)")
            }
        }
    }
    
    private func formatDate(_ string: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"

        if let date = inputFormatter.date(from: string) {
            return outputFormatter.string(from: date)
        }
        return nil
    }

    private func setApplications(apps: [JobApplication]) {
        self.jobApplications = apps
    }
}
