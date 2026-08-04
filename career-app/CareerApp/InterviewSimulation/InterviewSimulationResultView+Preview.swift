//
//  InterviewSimulationResultView+Preview.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 23/07/26.
//

#if DEBUG

extension InterviewSimulationEvaluation {
    static let previewMock = InterviewSimulationEvaluation(
        clarity: 86,
        objectivity: 78,
        examples: 72,
        technicalKnowledge: 91,
        responseTime: 83,
        overall: 84,
        summary: """
        A entrevista apresentou boas respostas técnicas, com domínio dos conceitos principais e comunicação clara.
        """,
        strengths: [
            "Bom domínio de Swift e arquitetura.",
            "Respostas claras e bem estruturadas.",
            "Boa compreensão sobre testes."
        ],
        improvements: [
            "Utilizar mais exemplos de projetos reais.",
            "Ser mais objetiva em respostas conceituais.",
            "Explicar melhor os impactos das decisões técnicas."
        ]
    )
}
#endif
