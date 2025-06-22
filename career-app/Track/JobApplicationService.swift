//
//  JobApplicationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/01/25.
//

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
    private let baseURL = APIConstants.baseURL
    
    func createJobApplication(_ jobApplication: JobApplicationRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/job-applications") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(jobApplication)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchJobApplications(completion: @escaping (Result<[JobApplicationRequest], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/job-applications") else {
            let error = URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network errors first
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check HTTP status code
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                completion(.failure(error))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = URLError(.badServerResponse, userInfo: [
                    NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"
                ])
                completion(.failure(error))
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                let error = URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            // Debug: Print raw JSON response
            print(String(data: data, encoding: .utf8) ?? "Invalid JSON data")
            
            // Parse JSON
            do {
                let decoder = JSONDecoder()
                // Configure date decoding strategy if needed
                // decoder.dateDecodingStrategy = .iso8601
                let applications = try decoder.decode([JobApplicationRequest].self, from: data)
                completion(.success(applications))
            } catch {
                print("Detailed decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
