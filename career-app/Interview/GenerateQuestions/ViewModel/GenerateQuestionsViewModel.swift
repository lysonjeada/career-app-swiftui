//
//  GenerateQuestionsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI
import Foundation

struct QuestionsGeneratorStep: Codable {
    let steps: [Step]
    
    struct Step: Codable, Identifiable, Hashable {
        var id = UUID()
        let title: String
        let description: String?
        let imageButton: String
        let type: StepType
        
        enum StepType: Codable, Hashable {
            case addCurriculum
            case addInfoJob
            case addDescriptionJob
        }
        
        enum CodingKeys: String, CodingKey {
            case title, description, imageButton, type
        }
    }
}

final class GenerateQuestionsViewModel: ObservableObject {
    private(set) var steps: [QuestionsGeneratorStep.Step]
    
    init() {
        self.steps = [
            .init(title: "Faça o download do seu currículo", description: "Certifique-se de que seu currículo está atualizado e com suas habilidades bem expostas.", imageButton: "doc.fill", type: .addCurriculum),
            .init(title: "Selecione cargo e senioridade", description: "Adicione cargo e senioridade correspondente a vaga", imageButton: "chevron.down", type: .addInfoJob),
            .init(title: "Adicione mais informações", description: "Adicione a descrição e/ou mais informações da vaga, isso ajuda o gerador de perguntas a ser mais assertivo", imageButton: "chevron.down", type: .addDescriptionJob)
        ]
    }
    
}
