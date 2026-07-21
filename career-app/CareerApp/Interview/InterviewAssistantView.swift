//
//  InterviewAssistantView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

struct InterviewAssistantView: View {
    @FocusState private var keyboardFocused: Bool

    @StateObject var viewModel:
        GenerateQuestionsViewModel

    @StateObject var resumeFeedbackViewModel:
        ResumeFeedbackViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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

                    NavigationLink {
                        InterviewSimulationFlowView()
                    } label: {
                        InterviewSimulationLauncherCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    InterviewGenerateQuestionsView(
                        viewModel: viewModel
                    )

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
