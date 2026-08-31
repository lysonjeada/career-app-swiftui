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
    let id: String
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


import SwiftUI
import Combine // Adicionar Combine se não estiver importado
import Foundation // Para UUID, caso não esteja

// Supondo que JobApplication, JobApplicationService, InterviewRequest já existam.
// Se não, adicione suas definições aqui para compilar.

class JobApplicationTrackerListViewModel: ObservableObject {
    private let service: JobApplicationServiceProtocol

    enum State: Equatable {
        case loading
        case loaded
    }

    @Published private(set) var viewState: State = .loading

    @Published var jobApplications: [JobApplication] = []
    @Published var showSnackBar: Bool = false // Novo: Controla a visibilidade da snack bar
    @Published var snackBarMessage: String = "" // Novo: Mensagem da snack bar

    private var task: Task<Void, Never>?
    private var snackBarTask: Task<Void, Never>?

    init(service: JobApplicationServiceProtocol = JobApplicationService()) {
        self.service = service
    }

    @MainActor
    func fetchJobApplications() {
        viewState = .loading

        task = Task {
            do {
                let interviews = try await service.fetchInterviews()
                let apps = interviews.map { JobApplication(from: $0) }

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
    @discardableResult
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String = "",
        skills: [String]
    ) async -> Bool {
        viewState = .loading

        do {
            try await service.addInterview(
                companyName: companyName,
                jobTitle: jobTitle,
                jobSeniority: jobSeniority,
                lastInterview: lastInterview,
                nextInterview: nextInterview,
                location: location,
                notes: notes,
                skills: skills
            )

            fetchJobApplications()

            showSuccessSnackBar(
                message: """
                Candidatura adicionada com sucesso!
                """
            )

            viewState = .loaded
            return true

        } catch {
            showErrorSnackBar(
                message: """
                Não foi possível adicionar a candidatura.
                """
            )

            viewState = .loaded
            return false
        }
    }

    @MainActor
    @discardableResult
    func editJob(
        id: String,
        company: String,
        role: String,
        level: String,
        lastInterview: String?,
        nextInterview: String?,
        technicalSkills: [String]
    ) async -> Bool {
        viewState = .loading

        // O formatDate() retorna Optional<String>, certifique-se que o InterviewRequest aceita nil
        let request = InterviewRequest(
            company_name: company,
            job_title: role,
            job_seniority: level,
            last_interview_date: formatDate(lastInterview ?? ""), // Passa Optional<String>
            next_interview_date: formatDate(nextInterview ?? ""), // Passa Optional<String>
            location: nil,
            notes: nil,
            skills: technicalSkills
        )

        do {
            try await service.updateInterview(interviewId: id, request: request)
            fetchJobApplications()
            viewState = .loaded
            showSuccessSnackBar(message: "Candidatura atualizada com sucesso!")
            return true
        } catch {
            showErrorSnackBar(message: "Não foi possível atualizar a candidatura.")
            viewState = .loaded // Ou mantenha em loading até a próxima fetch
            return false
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
        showSnackBar(message: message)
    }

    @MainActor
    private func showSuccessSnackBar(message: String) {
        showSnackBar(message: message)
    }

    @MainActor
    private func showSnackBar(message: String) {
        snackBarTask?.cancel()

        self.snackBarMessage = message
        self.showSnackBar = true

        snackBarTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))

            guard !Task.isCancelled else { return }

            self?.showSnackBar = false
            self?.snackBarMessage = "" // Limpa a mensagem
        }
    }
}
