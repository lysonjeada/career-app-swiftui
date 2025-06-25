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
    @Published var generatedQuestions: [String] = []
    
    private(set) var steps: [QuestionsGeneratorStep.Step]
    var service: APIServiceProtocol
    
    private var task: Task<Void, Never>?
    
    init(service: APIServiceProtocol = APIService()) {
        self.steps = [
            .init(title: "Faça o download do seu currículo", description: "Certifique-se de que seu currículo está atualizado e com suas habilidades bem expostas.", imageButton: "doc.fill", type: .addCurriculum),
            .init(title: "Selecione cargo e senioridade", description: "Adicione cargo e senioridade correspondente à vaga", imageButton: "chevron.down", type: .addInfoJob),
            .init(title: "Adicione mais informações", description: "Adicione a descrição e/ou mais informações da vaga, isso ajuda o gerador de perguntas a ser mais assertivo", imageButton: "chevron.down", type: .addDescriptionJob)
        ]
        self.service = service
    }
    
    @MainActor
    func generateQuestions(resumeURL: URL, jobTitle: String, seniority: String, description: String) {
        guard resumeURL.startAccessingSecurityScopedResource() else {
            print("❌ Falha ao acessar recurso protegido.")
            return
        }

        defer { resumeURL.stopAccessingSecurityScopedResource() }

        do {
            let pdfData = try Data(contentsOf: resumeURL)

            var request = URLRequest(url: URL(string: "http://192.168.0.9:8000/generate-interview-questions/")!)
            request.httpMethod = "POST"

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()

            // PDF
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"resume.pdf\"\r\n")
            body.append("Content-Type: application/pdf\r\n\r\n")
            body.append(pdfData)
            body.append("\r\n")

            // Campos de texto
            func appendTextField(_ name: String, _ value: String) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }

            appendTextField("job_title", jobTitle)
            appendTextField("seniority", seniority)
            appendTextField("description", description)

            body.append("--\(boundary)--\r\n")
            request.httpBody = body

            task = Task {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    if let decoded = try? JSONDecoder().decode(QuestionResponse.self, from: data) {
                        self.generatedQuestions = decoded.questions
                    } else {
                        print("❌ Falha ao decodificar resposta.")
                    }
                } catch {
                    print("❌ Erro na requisição: \(error.localizedDescription)")
                }
            }

        } catch {
            print("❌ Erro ao ler PDF: \(error.localizedDescription)")
        }
    }
}

struct QuestionResponse: Decodable {
    let questions: [String]
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
