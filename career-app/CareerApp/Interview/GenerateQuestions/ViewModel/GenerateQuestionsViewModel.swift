//
//  GenerateQuestionsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI
import Foundation

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
            case title
            case description
            case imageButton
            case type
        }
    }
}

@MainActor
final class GenerateQuestionsViewModel: ObservableObject {

    @Published private(set) var generatedQuestions: [String] = []
    @Published private(set) var viewState: State = .idle

    private(set) var steps: [QuestionsGeneratorStep.Step]

    private var task: Task<Void, Never>?

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    init() {
        self.steps = [
            .init(
                title: "Selecione cargo e senioridade",
                description: "Adicione cargo e senioridade correspondente à vaga",
                imageButton: "chevron.down",
                type: .addInfoJob
            ),
            .init(
                title: "Faça o upload do seu currículo",
                description: "Opcionalmente, envie seu currículo para gerar perguntas mais personalizadas.",
                imageButton: "doc.fill",
                type: .addCurriculum
            ),
            .init(
                title: "Adicione mais informações",
                description: "Opcionalmente, adicione a descrição ou mais informações da vaga",
                imageButton: "chevron.down",
                type: .addDescriptionJob
            )
        ]
    }

    func generateQuestions(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) {
        let normalizedJobTitle = jobTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let normalizedSeniority = seniority.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let normalizedDescription = description.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard isValidJobTitle(normalizedJobTitle) else {
            viewState = .error("Selecione um cargo antes de continuar.")
            return
        }

        guard isValidSeniority(normalizedSeniority) else {
            viewState = .error("Selecione uma senioridade antes de continuar.")
            return
        }

        task?.cancel()

        generatedQuestions = []
        viewState = .loading

        task = Task { [weak self] in
            guard let self else { return }

            do {
                /*
                 A criação do multipart pode ler um PDF relativamente grande.
                 Por isso, ela é executada fora da MainActor.
                 */
                let request = try await Task.detached(
                    priority: .userInitiated
                ) {
                    try Self.makeRequest(
                        resumeURL: resumeURL,
                        jobTitle: normalizedJobTitle,
                        seniority: normalizedSeniority,
                        description: normalizedDescription
                    )
                }.value

                let (data, response) = try await URLSession.shared.data(
                    for: request
                )

                try Task.checkCancellation()

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw GenerateQuestionsError.invalidResponse
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    let serverMessage = Self.extractServerMessage(from: data)

                    throw GenerateQuestionsError.serverError(
                        statusCode: httpResponse.statusCode,
                        message: serverMessage
                    )
                }

                let decodedResponse = try JSONDecoder().decode(
                    QuestionResponse.self,
                    from: data
                )

                let validQuestions = decodedResponse.questions
                    .map {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .filter {
                        !$0.isEmpty
                    }

                guard !validQuestions.isEmpty else {
                    throw GenerateQuestionsError.noQuestions
                }

                generatedQuestions = validQuestions
                viewState = .loaded

            } catch is CancellationError {
                // Uma nova geração substituiu a anterior.
            } catch {
                generatedQuestions = []
                viewState = .error(error.localizedDescription)

                print(
                    "❌ Erro ao gerar perguntas:",
                    error.localizedDescription
                )
            }
        }
    }

    func retry(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) {
        generateQuestions(
            resumeURL: resumeURL,
            jobTitle: jobTitle,
            seniority: seniority,
            description: description
        )
    }

    func cancelGeneration() {
        task?.cancel()
        task = nil
    }

    private func isValidJobTitle(_ jobTitle: String) -> Bool {
        !jobTitle.isEmpty && jobTitle.lowercased() != "cargo"
    }

    private func isValidSeniority(_ seniority: String) -> Bool {
        !seniority.isEmpty &&
        seniority.lowercased() != "senioridade"
    }
}

private extension GenerateQuestionsViewModel {

    nonisolated static func makeRequest(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) throws -> URLRequest {
        guard let endpoint = URL(
            string: "\(APIConstants.pythonURL)/generate-interview-questions/"
        ) else {
            throw GenerateQuestionsError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 120

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        // Obrigatórios
        body.appendFormField(
            name: "job_title",
            value: jobTitle,
            boundary: boundary
        )

        body.appendFormField(
            name: "seniority",
            value: seniority,
            boundary: boundary
        )

        // Opcional
        if !description.isEmpty {
            body.appendFormField(
                name: "description",
                value: description,
                boundary: boundary
            )
        }

        // Opcional
        if let resumeURL {
            let pdfData = try readResumeData(from: resumeURL)

            body.appendFile(
                name: "resume",
                filename: resumeURL.lastPathComponent.isEmpty
                    ? "resume.pdf"
                    : resumeURL.lastPathComponent,
                mimeType: "application/pdf",
                fileData: pdfData,
                boundary: boundary
            )
        }

        body.appendString("--\(boundary)--\r\n")

        request.httpBody = body

        return request
    }

    nonisolated static func readResumeData(
        from resumeURL: URL
    ) throws -> Data {
        /*
         URLs copiadas para o sandbox podem retornar false aqui e ainda
         serem legíveis. Por isso, false não é tratado como erro.
         */
        let startedAccess =
            resumeURL.startAccessingSecurityScopedResource()

        defer {
            if startedAccess {
                resumeURL.stopAccessingSecurityScopedResource()
            }
        }

        do {
            return try Data(
                contentsOf: resumeURL,
                options: .mappedIfSafe
            )
        } catch {
            throw GenerateQuestionsError.couldNotReadResume(
                error.localizedDescription
            )
        }
    }

    nonisolated static func extractServerMessage(
        from data: Data
    ) -> String? {
        if let response = try? JSONDecoder().decode(
            ServerErrorResponse.self,
            from: data
        ) {
            return response.detail
        }

        return String(data: data, encoding: .utf8)
    }
}

private extension Data {

    mutating func appendString(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }

        append(data)
    }

    mutating func appendFormField(
        name: String,
        value: String,
        boundary: String
    ) {
        appendString("--\(boundary)\r\n")

        appendString(
            "Content-Disposition: form-data; " +
            "name=\"\(name)\"\r\n\r\n"
        )

        appendString("\(value)\r\n")
    }

    mutating func appendFile(
        name: String,
        filename: String,
        mimeType: String,
        fileData: Data,
        boundary: String
    ) {
        appendString("--\(boundary)\r\n")

        appendString(
            "Content-Disposition: form-data; " +
            "name=\"\(name)\"; " +
            "filename=\"\(filename)\"\r\n"
        )

        appendString("Content-Type: \(mimeType)\r\n\r\n")
        append(fileData)
        appendString("\r\n")
    }
}

private enum GenerateQuestionsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case couldNotReadResume(String)
    case serverError(statusCode: Int, message: String?)
    case noQuestions

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "A URL usada para gerar as perguntas é inválida."

        case .invalidResponse:
            return "O servidor retornou uma resposta inválida."

        case let .couldNotReadResume(message):
            return "Não foi possível ler o currículo: \(message)"

        case let .serverError(statusCode, message):
            if let message, !message.isEmpty {
                return "Erro \(statusCode): \(message)"
            }

            return "O servidor retornou o erro \(statusCode)."

        case .noQuestions:
            return "O servidor não retornou nenhuma pergunta."
        }
    }
}

private struct ServerErrorResponse: Decodable {
    let detail: String?
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
