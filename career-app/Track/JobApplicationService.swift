//
//  JobApplicationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/01/25.
//

import Foundation

struct JobApplicationRequest: Codable {
    let company: String
    let level: String
    let lastInterview: String?
    let nextInterview: String?
    let technicalSkills: [String]
}

class JobApplicationService {
    private let baseURL = "career-app-vapor-3e22c9ffa7af.herokuapp.com"
    
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
}
