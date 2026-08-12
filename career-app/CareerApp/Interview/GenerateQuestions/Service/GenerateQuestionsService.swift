//
//  GenerateQuestionsService.swift
//  career-app
//

import Foundation

protocol GenerateQuestionsServiceProtocol {
    func generateQuestions(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String]
}

final class GenerateQuestionsService: GenerateQuestionsServiceProtocol {

    func generateQuestions(
        resumeURL: URL?,
        jobTitle: String,
        seniority: String,
        description: String
    ) async throws -> [String] {
        /*
         A criação do multipart pode ler um PDF relativamente grande.
         Por isso, ela é executada fora da MainActor.
         */
        let request = try await Task.detached(
            priority: .userInitiated
        ) {
            try Self.makeRequest(
                resumeURL: resumeURL,
                jobTitle: jobTitle,
                seniority: seniority,
                description: description
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

        return validQuestions
    }
}

private extension GenerateQuestionsService {

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
