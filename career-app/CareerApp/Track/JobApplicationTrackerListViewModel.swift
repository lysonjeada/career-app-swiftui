//
//  JobApplicationTrackerListViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/06/25.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Para dates, ou "yyyy-MM-dd'T'HH:mm:ss" para datetime
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // GMT para consistência se não houver timezone no backend
        return formatter
    }()
}

struct InterviewResponse: Codable {
    let id: UUID
    let company_name: String
    let job_seniority: String
    let job_title: String
    let last_interview_date: Date?
    let next_interview_date: Date?
    let location: String?
    let notes: String?
    let skills: [String]?
    let created_at: String
    let updated_at: String
}


import SwiftUI
import Combine // Adicionar Combine se não estiver importado
import Foundation // Para UUID, caso não esteja

// Supondo que JobApplication, JobApplicationService, InterviewRequest já existam.
// Se não, adicione suas definições aqui para compilar.

class JobApplicationTrackerListViewModel: ObservableObject {
    private let service = JobApplicationService()

    enum State: Equatable {
        case loading
        case loaded
    }

    @Published private(set) var viewState: State = .loading

    @Published var jobApplications: [JobApplication] = []
    @Published var showSnackBar: Bool = false // Novo: Controla a visibilidade da snack bar
    @Published var snackBarMessage: String = "" // Novo: Mensagem da snack bar

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
                        level: $0.job_seniority,
                        role: $0.job_title,
                        lastInterview: $0.last_interview_date?.toDayMonthString(),
                        nextInterview: $0.next_interview_date?.toDayMonthString(),
                        technicalSkills: $0.skills ?? []
                    )
                }

                setApplications(apps: apps)
                self.viewState = .loaded
            } catch {
                // print("❌ Erro ao buscar entrevistas: \(error.localizedDescription)") // REMOVIDO
                showErrorSnackBar(message: "Falha ao carregar candidaturas.")
                self.viewState = .loaded // Ou .error, dependendo de como você quer tratar o estado de erro
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
                self?.showSuccessSnackBar(message: "Candidatura excluída com sucesso!")
            } catch {
                // print("❌ Erro ao atualizar entrevista: \(error.localizedDescription)") // REMOVIDO
                self?.showErrorSnackBar(message: "Não foi possível excluir a candidatura.")
                self?.viewState = .loaded // Ou mantenha em loading até a próxima fetch
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
                self.showSuccessSnackBar(message: "Candidatura adicionada com sucesso!")

            } catch {
                // print("❌ Erro ao adicionar entrevista: \(error.localizedDescription)") // REMOVIDO
                self?.showErrorSnackBar(message: "Não foi possível adicionar a candidatura.")
                self?.viewState = .loaded // Ou mantenha em loading até a próxima fetch
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
                guard let self else { return }

                // O formatDate() retorna Optional<String>, certifique-se que o InterviewRequest aceita nil
                let request = InterviewRequest(
                    company_name: company,
                    job_title: role,
                    job_seniority: level,
                    last_interview_date: self.formatDate(lastInterview ?? ""), // Passa Optional<String>
                    next_interview_date: self.formatDate(nextInterview ?? ""), // Passa Optional<String>
                    location: nil,
                    notes: nil,
                    skills: technicalSkills
                )

                try await self.service.updateInterview(interviewId: id.uuidString, request: request)
                self.fetchJobApplications()
                self.viewState = .loaded
                self.showSuccessSnackBar(message: "Candidatura atualizada com sucesso!")
            } catch {
                // print("❌ Erro ao atualizar entrevista: \(error.localizedDescription)") // REMOVIDO
                self?.showErrorSnackBar(message: "Não foi possível atualizar a candidatura.")
                self?.viewState = .loaded // Ou mantenha em loading até a próxima fetch
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

    // MARK: - SnackBar Logic

    @MainActor
    private func showErrorSnackBar(message: String) {
        self.snackBarMessage = message
        self.showSnackBar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Esconde após 3 segundos
            self.showSnackBar = false
            self.snackBarMessage = "" // Limpa a mensagem
        }
    }

    @MainActor
    private func showSuccessSnackBar(message: String) {
        self.snackBarMessage = message
        self.showSnackBar = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Esconde após 3 segundos
            self.showSnackBar = false
            self.snackBarMessage = "" // Limpa a mensagem
        }
    }
}
