//
//  InterviewAssistantCoordinator.swift
//  career-app
//

import SwiftUI

/// Navegação da aba "Entrevistas" — tem seu próprio NavigationPath (não
/// o do Coordinator raiz), porque essa tela vive dentro da TabView e um
/// push no path raiz esconderia a tab bar. Por isso é o único
/// sub-coordinator que precisa ser ObservableObject: a View faz
/// `NavigationStack(path: $interviewAssistant.path)` diretamente sobre
/// ele, não através do Coordinator raiz.
@MainActor
final class InterviewAssistantCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ page: InterviewAssistantPage) {
        path.append(page)
    }

    func pop() {
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }

    @ViewBuilder
    func build(_ page: InterviewAssistantPage) -> some View {
        switch page {
        case .interviewSimulation:
            InterviewSimulationFlowView()
        case .studyPlan:
            StudyPlanFlowView()
        }
    }
}

enum InterviewAssistantPage: Hashable {
    case interviewSimulation
    case studyPlan
}
