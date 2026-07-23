//
//  StudyPlanViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import Foundation

@MainActor
final class StudyPlanViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var studyPlan: StudyPlan?

    private let service: StudyPlanServiceProtocol

    private var lastRequest:
        StudyPlanRequestContext?

    init(
        service: StudyPlanServiceProtocol =
            StudyPlanService()
    ) {
        self.service = service
    }

    var completedTopicsCount: Int {
        studyPlan?.topics.filter {
            $0.isCompleted
        }.count ?? 0
    }

    var totalTopicsCount: Int {
        studyPlan?.topics.count ?? 0
    }

    var progress: Double {
        guard totalTopicsCount > 0 else {
            return 0
        }

        return Double(completedTopicsCount) /
            Double(totalTopicsCount)
    }

    func generateStudyPlan(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) async {
        let normalizedJobTitle =
            jobTitle.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let normalizedSeniority =
            seniority.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let normalizedDescription =
            description.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !normalizedJobTitle.isEmpty else {
            state = .error(
                "Informe o cargo desejado."
            )
            return
        }

        guard !normalizedSeniority.isEmpty,
              normalizedSeniority != "Senioridade" else {
            state = .error(
                "Selecione a senioridade."
            )
            return
        }

        lastRequest = StudyPlanRequestContext(
            jobTitle: normalizedJobTitle,
            seniority: normalizedSeniority,
            description: normalizedDescription,
            resumeURL: resumeURL
        )

        state = .loading
        studyPlan = nil

        do {
            studyPlan = try await service.generateStudyPlan(
                jobTitle: normalizedJobTitle,
                seniority: normalizedSeniority,
                description: normalizedDescription,
                resumeURL: resumeURL
            )

            state = .loaded

        } catch {
            state = .error(
                error.localizedDescription
            )
        }
    }

    func retry() async {
        guard let lastRequest else {
            state = .idle
            return
        }

        await generateStudyPlan(
            jobTitle: lastRequest.jobTitle,
            seniority: lastRequest.seniority,
            description: lastRequest.description,
            resumeURL: lastRequest.resumeURL
        )
    }

    func toggleTopic(
        id: UUID
    ) {
        guard var updatedPlan = studyPlan,
              let index = updatedPlan.topics.firstIndex(
                where: {
                    $0.id == id
                }
              ) else {
            return
        }

        updatedPlan.topics[index]
            .isCompleted.toggle()

        studyPlan = updatedPlan
    }

    func restart() {
        state = .idle
        studyPlan = nil
        lastRequest = nil
    }
}

private struct StudyPlanRequestContext {
    let jobTitle: String
    let seniority: String
    let description: String
    let resumeURL: URL?
}
