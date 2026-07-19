//
//  InterviewService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import Foundation

struct ResumeFeedbackResponse: Codable {
    let feedback: String
}

final class InterviewService {
    static let shared = InterviewService()
    private init() {}

    func fetchResumeFeedback(resumeURL: URL) async throws -> ResumeFeedbackResponse {
        guard resumeURL.startAccessingSecurityScopedResource() else {
            throw URLError(.noPermissionsToReadFile)
        }
        defer { resumeURL.stopAccessingSecurityScopedResource() }

        let pdfData = try Data(contentsOf: resumeURL)

        var request = URLRequest(url: URL(string: "\(APIConstants.pythonURL)/resume-feedback/")!)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        var body = Data()

        // PDF
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"resume.pdf\"\r\n")
        body.append("Content-Type: application/pdf\r\n\r\n")
        body.append(pdfData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ResumeFeedbackResponse.self, from: data)
        return decoded
    }
}

extension InterviewService {
    func submitFeedbackAndGetTaskID(resumeURL: URL) async throws -> String {
        print("📥 Iniciando envio do currículo...")

        guard resumeURL.startAccessingSecurityScopedResource() else {
            print("❌ Falha ao acessar SecurityScopedResource")
            throw URLError(.noPermissionsToReadFile)
        }
        defer {
            resumeURL.stopAccessingSecurityScopedResource()
            print("📁 Encerrado acesso ao recurso protegido")
        }

        print("📄 Tentando ler o conteúdo do PDF em: \(resumeURL.path)")
        let pdfData: Data
        do {
            pdfData = try Data(contentsOf: resumeURL)
            print("✅ PDF lido com sucesso, tamanho: \(pdfData.count) bytes")
        } catch {
            print("❌ Erro ao ler PDF: \(error.localizedDescription)")
            throw error
        }

        guard let url = URL(string: "\(APIConstants.pythonURL)/submit-feedback/") else {
            print("❌ URL inválida para submit-feedback")
            throw URLError(.badURL)
        }

        print("🌐 Criando requisição para: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"resume\"; filename=\"resume.pdf\"\r\n")
        body.append("Content-Type: application/pdf\r\n\r\n")
        body.append(pdfData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")

        print("📤 Enviando requisição com body de \(body.count) bytes")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Resposta recebida com status code: \(httpResponse.statusCode)")
            }

            let responseString = String(data: data, encoding: .utf8) ?? "n/a"
            print("📨 Conteúdo da resposta: \(responseString.prefix(300))...")

            let decoded = try JSONDecoder().decode(ResumeFeedbackSubmissionResponse.self, from: data)
            print("✅ Task ID recebida: \(decoded.task_id)")
            return decoded.task_id
        } catch {
            print("❌ Erro ao enviar requisição: \(error.localizedDescription)")
            throw error
        }
    }

    func checkFeedbackStatus(taskID: String) async throws -> Bool {
        let url = URL(string: "\(APIConstants.pythonURL)/feedback-status/\(taskID)")!
        print("🔄 Checando status do task_id: \(taskID)")
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: String]
        let status = json?["status"] ?? "unknown"
        print("📡 Status atual da task: \(status)")
        return status == "SUCCESS"
    }

    func fetchFeedbackResult(taskID: String) async throws -> String {
        let url = URL(string: "\(APIConstants.pythonURL)/feedback-result/\(taskID)")!
        print("📥 Buscando resultado da task: \(taskID)")
        let (data, _) = try await URLSession.shared.data(from: url)

        let stringResponse = String(data: data, encoding: .utf8) ?? "n/a"
        print("📨 Conteúdo da resposta final: \(stringResponse.prefix(300))...")

        let result = try JSONDecoder().decode(ResumeFeedbackResponse.self, from: data)
        print("✅ Feedback final recebido com sucesso!")
        return result.feedback
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
