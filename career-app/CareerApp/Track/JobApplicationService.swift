//
//  JobApplicationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/01/25.
//

// private let baseURL = APIConstants.baseURL

import Foundation

struct JobApplicationRequest: Codable {
    let company: String
    let role: String
    let level: String
    let lastInterview: String?
    let nextInterview: String?
    let technicalSkills: [String]
}

class JobApplicationService {
    func fetchInterviews() async throws -> [InterviewResponse] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (GET): \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Resposta JSON:")
            print(jsonString)
        }

        return try JSONDecoder().decode([InterviewResponse].self, from: data)
    }
}

