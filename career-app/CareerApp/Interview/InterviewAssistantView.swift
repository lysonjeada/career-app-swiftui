//
//  InterviewAssistantView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

struct InterviewAssistantView: View {
    @FocusState private var keyboardFocused: Bool

    @ObservedObject var interviewAssistant: InterviewAssistantCoordinator

    @StateObject var viewModel:
        GenerateQuestionsViewModel = GenerateQuestionsViewModel()

    @StateObject var resumeFeedbackViewModel:
        ResumeFeedbackViewModel = ResumeFeedbackViewModel()

    var body: some View {
        NavigationStack(path: $interviewAssistant.path) {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressDashboardSection()
                            .padding(.top, 16)

                    StudyPlanSection(interviewAssistant: interviewAssistant)
                    
                    Text("Simulador de entrevista")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.persianBlue)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                        .padding(.horizontal)
                        .shadow(
                            color: .gray.opacity(0.3),
                            radius: 1,
                            x: 0,
                            y: 1
                        )
                        .padding(.top, 24)

                    Button {
                        interviewAssistant.push(.interviewSimulation)
                    } label: {
                        InterviewSimulationLauncherCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    Text("Melhore seu currículo")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.persianBlue)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                        .padding(.horizontal)
                        .shadow(
                            color: .gray.opacity(0.3),
                            radius: 1,
                            x: 0,
                            y: 1
                        )

                    ResumeFeedbackView(
                        viewModel: resumeFeedbackViewModel
                    )
                }
            }
            .ignoresSafeArea(.keyboard)
            .gesture(
                DragGesture().onChanged { _ in
                    UIApplication.shared.sendAction(
                        #selector(
                            UIResponder.resignFirstResponder
                        ),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            )
            .navigationDestination(for: InterviewAssistantPage.self) { page in
                interviewAssistant.build(page)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    keyboardFocused = false
                }
            }
        }
    }
}

#if DEBUG

@MainActor
private struct InterviewAssistantPreviewContainer: View {
    @StateObject private var questionsViewModel =
        GenerateQuestionsViewModel()

    @StateObject private var resumeFeedbackViewModel =
        ResumeFeedbackViewModel()

    var body: some View {
        InterviewAssistantView(
            interviewAssistant: InterviewAssistantCoordinator(),
            viewModel: questionsViewModel,
            resumeFeedbackViewModel: resumeFeedbackViewModel
        )
    }
}

#Preview("Interview Assistant — Light") {
    InterviewAssistantPreviewContainer()
        .preferredColorScheme(.light)
}

#Preview("Interview Assistant — Dark") {
    InterviewAssistantPreviewContainer()
        .preferredColorScheme(.dark)
}

#endif
