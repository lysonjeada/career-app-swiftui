//
//  InterviewQuestionsView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 22/10/24.
//

import SwiftUI

struct InterviewQuestionsView: View {
    let questions: [String] // Lista de perguntas geradas
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Generated Interview Questions")
                .font(.title)
                .lineLimit(nil)
                .padding(.bottom, 20)
            
            // Exibe cada pergunta com uma bullet point
            ForEach(questions, id: \.self) { question in
                Text("• \(question)")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.bottom, 10)
            }
            
            Spacer() // Empurra o conteúdo para o topo
        }
        .padding()
        .navigationTitle("Questions")
        .navigationBarTitleDisplayMode(.inline) // Exibe o título no centro da navigation bar
    }
}

struct InterviewQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewQuestionsView(questions: [])
    }
}
