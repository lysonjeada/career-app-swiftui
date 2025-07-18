//
//  JobApplicationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/01/25.
//

// private let baseURL = APIConstants.baseURL

import Foundation

protocol JobApplicationServiceProtocol {
    func fetchInterviews() async throws -> [InterviewResponse]
    func fetchNextInterviews() async throws -> [InterviewResponse]
    func fetchJobListings(repository: String?) async throws -> [GitHubJobListing]
    func fetchAvailableRepositories() async throws -> [String]
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String,
        skills: [String]
    ) async throws
    func updateInterview(interviewId: String, request: InterviewRequest) async throws
    func deleteInterview(interviewId: String) async throws
}

class JobApplicationService: JobApplicationServiceProtocol {
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
    
    func fetchNextInterviews() async throws -> [InterviewResponse] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/next/") else {
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
    
    func updateInterview(interviewId: String, request: InterviewRequest) async throws {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/\(interviewId)") else {
            throw URLError(.badURL)
        }
        
        var requestData = URLRequest(url: url)
        requestData.httpMethod = "PUT"
        requestData.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestData.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: requestData)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (PUT): \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Resposta JSON (PUT):")
            print(jsonString)
        }
    }
    
    func deleteInterview(interviewId: String) async throws {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/\(interviewId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("\u{2705} Código de resposta (DELETE): \(httpResponse.statusCode)")
        }
    }
    
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String = "",
        skills: [String]
    ) async throws {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        
        func formatDate(_ string: String) -> String? {
            guard let date = inputFormatter.date(from: string) else { return nil }
            return outputFormatter.string(from: date)
        }
        
        let requestBody = InterviewRequest(
            company_name: companyName,
            job_title: jobTitle,
            job_seniority: jobSeniority,
            last_interview_date: formatDate(lastInterview),
            next_interview_date: formatDate(nextInterview),
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            skills: skills.isEmpty ? nil : skills
        )
        
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/") else {
            throw URLError(.badURL)
        }
        
        let data = try JSONEncoder().encode(requestBody)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Corpo da requisição JSON:")
            print(jsonString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (POST): \(httpResponse.statusCode)")
        }
        
        if let responseBody = String(data: responseData, encoding: .utf8) {
            print("📥 Resposta do servidor:")
            print(responseBody)
        }
    }
}

extension JobApplicationService {
    func fetchJobListings(repository: String? = nil) async throws -> [GitHubJobListing] {
        var urlString = "\(APIConstants.pythonURL)/job-listings/"
        
        if let repository = repository, !repository.isEmpty {
            // Escapa caracteres especiais para URL (como /)
            if let encodedRepo = repository.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlString += "?repository=\(encodedRepo)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (GET Job Listings): \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Resposta JSON Job Listings:")
            print(jsonString)
        }
        
        return try JSONDecoder().decode([GitHubJobListing].self, from: data)
    }
}


extension JobApplicationService {
    func fetchAvailableRepositories() async throws -> [String] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/repositories-available/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (GET Repositories): \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Repositórios disponíveis:")
            print(jsonString)
        }

        return try JSONDecoder().decode([String].self, from: data)
    }
}
