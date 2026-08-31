//
//  TrackCoordinator.swift
//  career-app
//

import SwiftUI

/// Navegação do fluxo de candidaturas (adicionar/editar) — empurra no
/// `path` compartilhado do Coordinator raiz.
@MainActor
final class TrackCoordinator {
    weak var root: Coordinator?

    var jobApplicationTrackerListViewModel = JobApplicationTrackerListViewModel()

    func push(_ route: TrackRoute) {
        root?.path.append(route)
    }

    func pop() {
        root?.pop()
    }

    @ViewBuilder
    func build(_ route: TrackRoute) -> some View {
        switch route {
        case .addJob:
            AddJobApplicationForm(viewModel: self.jobApplicationTrackerListViewModel, coordinator: self)

        case .editJob(let job):
            EditJobApplicationView(job: job, coordinator: self, viewModel: self.jobApplicationTrackerListViewModel)
        }
    }
}

enum TrackRoute: Hashable {
    case addJob
    case editJob(JobApplication)
}
