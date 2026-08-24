//
//  StudyPlanService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 22/07/26.
//

import Foundation

protocol StudyPlanServiceProtocol {
    func generateStudyPlan(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) async throws -> StudyPlan
}

final class StudyPlanService: StudyPlanServiceProtocol {

    func generateStudyPlan(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) async throws -> StudyPlan {
        let request = try await Task.detached(
            priority: .userInitiated
        ) {
            try Self.makeRequest(
                jobTitle: jobTitle,
                seniority: seniority,
                description: description,
                resumeURL: resumeURL
            )
        }.value

        let (data, response) = try await AuthenticatedHTTPClient.shared.data(
            for: request
        )

        try validate(
            response: response,
            data: data
        )

        do {
            let decoded = try JSONDecoder().decode(
                StudyPlanResponseDTO.self,
                from: data
            )

            return decoded.toDomain()

        } catch {
            let responseContent = String(
                data: data,
                encoding: .utf8
            )

            print(
                "❌ Resposta inválida do plano:",
                responseContent ?? "Sem conteúdo"
            )

            throw StudyPlanServiceError.decodingFailed(
                error.localizedDescription
            )
        }
    }

    private static func makeRequest(
        jobTitle: String,
        seniority: String,
        description: String,
        resumeURL: URL?
    ) throws -> URLRequest {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)/study-plan/generate"
        ) else {
            throw StudyPlanServiceError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.timeoutInterval = 180

        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.appendMultipartField(
            name: "job_title",
            value: jobTitle,
            boundary: boundary
        )

        body.appendMultipartField(
            name: "seniority",
            value: seniority,
            boundary: boundary
        )

        if !description.isEmpty {
            body.appendMultipartField(
                name: "description",
                value: description,
                boundary: boundary
            )
        }

        if let resumeURL {
            let pdfData = try readResumeData(
                from: resumeURL
            )

            body.appendMultipartFile(
                name: "resume",
                filename: resumeURL.lastPathComponent.isEmpty
                    ? "resume.pdf"
                    : resumeURL.lastPathComponent,
                mimeType: "application/pdf",
                fileData: pdfData,
                boundary: boundary
            )
        }

        body.appendUTF8(
            "--\(boundary)--\r\n"
        )

        request.httpBody = body

        return request
    }

    private static func readResumeData(
        from url: URL
    ) throws -> Data {
        let hasSecurityAccess =
            url.startAccessingSecurityScopedResource()

        defer {
            if hasSecurityAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            return try Data(
                contentsOf: url,
                options: .mappedIfSafe
            )
        } catch {
            throw StudyPlanServiceError.resumeReadFailed(
                error.localizedDescription
            )
        }
    }

    private func validate(
        response: URLResponse,
        data: Data
    ) throws {
        guard let httpResponse =
                response as? HTTPURLResponse else {
            throw StudyPlanServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.from(
                statusCode: httpResponse.statusCode,
                data: data
            )
        }
    }
}

private struct StudyPlanResponseDTO: Decodable {
    let title: String
    let summary: String
    let estimatedTotalHours: Int
    let topics: [StudyPlanTopicDTO]

    enum CodingKeys: String, CodingKey {
        case title
        case summary
        case estimatedTotalHours = "estimated_total_hours"
        case topics
    }

    func toDomain() -> StudyPlan {
        StudyPlan(
            title: title,
            summary: summary,
            estimatedTotalHours: estimatedTotalHours,
            topics: topics.map {
                $0.toDomain()
            }
        )
    }
}

private struct StudyPlanTopicDTO: Decodable {
    let title: String
    let description: String
    let priority: String
    let estimatedHours: Int
    let subtopics: [String]
    let practice: String

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case priority
        case estimatedHours = "estimated_hours"
        case subtopics
        case practice
    }

    func toDomain() -> StudyPlanTopic {
        StudyPlanTopic(
            title: title,
            description: description,
            priority: StudyPlanPriority(
                rawValue: priority.lowercased()
            ) ?? .medium,
            estimatedHours: estimatedHours,
            subtopics: subtopics,
            practice: practice
        )
    }
}

private extension Data {

    mutating func appendUTF8(
        _ string: String
    ) {
        guard let data = string.data(
            using: .utf8
        ) else {
            return
        }

        append(data)
    }

    mutating func appendMultipartField(
        name: String,
        value: String,
        boundary: String
    ) {
        appendUTF8("--\(boundary)\r\n")

        appendUTF8(
            """
            Content-Disposition: form-data; name="\(name)"\r\n\r\n
            """
        )

        appendUTF8("\(value)\r\n")
    }

    mutating func appendMultipartFile(
        name: String,
        filename: String,
        mimeType: String,
        fileData: Data,
        boundary: String
    ) {
        appendUTF8("--\(boundary)\r\n")

        appendUTF8(
            """
            Content-Disposition: form-data; name="\(name)"; filename="\(filename)"\r\n
            """
        )

        appendUTF8(
            "Content-Type: \(mimeType)\r\n\r\n"
        )

        append(fileData)
        appendUTF8("\r\n")
    }
}
