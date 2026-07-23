//
//  StudyPlanResultView+Preview.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

import Foundation
import SwiftUI


struct StudyPlanResultPreviewContainer: View {

    @StateObject private var viewModel:
        StudyPlanViewModel

    init() {
        let service = StudyPlanServiceMock(
            studyPlan: .previewMock
        )

        _viewModel = StateObject(
            wrappedValue: StudyPlanViewModel(
                service: service
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.studyPlan != nil {
                    StudyPlanResultView(
                        viewModel: viewModel,
                        closeAction: {
                            print("Preview finalizado")
                        }
                    )
                } else {
                    ProgressView(
                        "Carregando plano..."
                    )
                }
            }
            .navigationTitle("Plano de estudos")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                guard viewModel.studyPlan == nil else {
                    return
                }

                await viewModel.generateStudyPlan(
                    jobTitle: "iOS Developer",
                    seniority: "Mid-level",
                    description: """
                    Desenvolvimento de aplicativos iOS utilizando Swift, \
                    SwiftUI, MVVM, testes automatizados e integração com APIs.
                    """,
                    resumeURL: nil
                )
            }
        }
    }
}

#if DEBUG

private final class StudyPlanServiceMock:
    StudyPlanServiceProtocol {

    private let studyPlan: StudyPlan

    init(
        studyPlan: StudyPlan = .previewMock
    ) {
        self.studyPlan = studyPlan
    }

    func generateStudyPlan(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) async throws -> StudyPlan {
        studyPlan
    }
}

private extension StudyPlan {

    static let previewMock = StudyPlan(
        title: "Plano de estudos para iOS Developer Pleno",
        summary: """
        Esta trilha foi criada para fortalecer conhecimentos em Swift, \
        arquitetura, concorrência e testes, preparando você para processos \
        seletivos de nível pleno.
        """,
        estimatedTotalHours: 32,
        topics: [
            StudyPlanTopic(
                title: "Swift avançado",
                description: """
                Revise os principais recursos da linguagem necessários para \
                escrever códigos seguros, reutilizáveis e eficientes.
                """,
                priority: .high,
                estimatedHours: 6,
                subtopics: [
                    "Generics e associated types",
                    "Protocols e protocol extensions",
                    "Value types e reference types",
                    "Optional handling",
                    "Gerenciamento de memória com ARC"
                ],
                practice: """
                Crie uma camada de networking genérica utilizando protocols, \
                generics e async/await.
                """,
                isCompleted: true
            ),

            StudyPlanTopic(
                title: "Concorrência com async/await",
                description: """
                Aprenda a trabalhar com operações assíncronas, cancelamento \
                de tarefas e atualização segura da interface.
                """,
                priority: .high,
                estimatedHours: 5,
                subtopics: [
                    "Task e TaskGroup",
                    "MainActor",
                    "AsyncSequence",
                    "Cancelamento de tarefas",
                    "Tratamento de erros assíncronos"
                ],
                practice: """
                Implemente uma tela que carregue dados de diferentes endpoints \
                simultaneamente e permita cancelar as requisições.
                """,
                isCompleted: true
            ),

            StudyPlanTopic(
                title: "Arquitetura e organização de código",
                description: """
                Entenda como dividir responsabilidades e construir aplicações \
                que sejam fáceis de testar e evoluir.
                """,
                priority: .high,
                estimatedHours: 7,
                subtopics: [
                    "MVVM",
                    "Coordinator",
                    "Clean Architecture",
                    "Injeção de dependência",
                    "Separação entre domínio e infraestrutura"
                ],
                practice: """
                Refatore uma funcionalidade existente utilizando MVVM, service \
                protocol e injeção de dependência.
                """,
                isCompleted: false
            ),

            StudyPlanTopic(
                title: "Testes automatizados",
                description: """
                Pratique testes unitários para ViewModels, services e regras \
                de negócio.
                """,
                priority: .medium,
                estimatedHours: 5,
                subtopics: [
                    "XCTest",
                    "Mocks, spies e stubs",
                    "Testes assíncronos",
                    "Snapshot Testing",
                    "Testes de estados do ViewModel"
                ],
                practice: """
                Crie testes para validar os estados loading, loaded e error \
                de uma tela que consome uma API.
                """,
                isCompleted: false
            ),

            StudyPlanTopic(
                title: "SwiftUI e gerenciamento de estado",
                description: """
                Aprofunde o uso de SwiftUI para construir interfaces \
                reativas e componentizadas.
                """,
                priority: .medium,
                estimatedHours: 5,
                subtopics: [
                    "@State e @Binding",
                    "@StateObject e @ObservedObject",
                    "NavigationStack",
                    "ViewBuilder",
                    "Criação de componentes reutilizáveis"
                ],
                practice: """
                Desenvolva uma tela com formulário, loading, tratamento \
                de erro e navegação para uma tela de resultado.
                """,
                isCompleted: false
            ),

            StudyPlanTopic(
                title: "CI/CD para projetos iOS",
                description: """
                Conheça práticas de automação para garantir qualidade e \
                facilitar a distribuição do aplicativo.
                """,
                priority: .low,
                estimatedHours: 4,
                subtopics: [
                    "GitHub Actions",
                    "Fastlane",
                    "Execução automatizada de testes",
                    "Distribuição pelo TestFlight"
                ],
                practice: """
                Configure uma pipeline que execute os testes do projeto \
                a cada pull request.
                """,
                isCompleted: false
            )
        ]
    )
}

#endif
