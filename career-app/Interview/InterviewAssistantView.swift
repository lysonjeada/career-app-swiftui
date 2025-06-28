//
//  InterviewAssistantView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import SwiftUI

struct InterviewAssistantView: View {
    @FocusState private var keyboardFocused: Bool
    @StateObject var viewModel: GenerateQuestionsViewModel
    @StateObject var resumeFeedbackViewModel: ResumeFeedbackViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Gere perguntas para uma possível entrevista")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.adaptiveBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 24)
                    InterviewGenerateQuestionsView(viewModel: viewModel)
                    Text("Melhore seu currículo")
                        .font(.title2)
                        .bold()
                        .foregroundColor(Color.adaptiveBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    ResumeFeedbackView(viewModel: resumeFeedbackViewModel)
                }
            }
            .ignoresSafeArea(.keyboard)
            .gesture(DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // the Spacer will push the Done button to the far right of the keyboard as pictured.
                Spacer()
                
                Button(action: {
                    keyboardFocused = false
                }, label: {
                    Text("Done")
                })
                
            }
        }
    }
}
