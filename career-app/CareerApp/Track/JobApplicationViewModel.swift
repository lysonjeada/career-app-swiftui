//
//  JobApplicationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/01/25.
//

import Foundation

struct InterviewRequest: Codable {
    let company_name: String
    let job_title: String
    let job_seniority: String
    let last_interview_date: String?  // formato "yyyy-MM-dd"
    let next_interview_date: String?
    let location: String?
    let notes: String?
    let skills: [String]?
}


class AddJobApplicationViewModel: ObservableObject {
    private let service = JobApplicationService()
    @Published var jobApplications: [JobApplication] = []
    private var task: Task<Void, Never>?
    
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String = "",
        skills: [String]
    ) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        
        func formatDate(_ string: String) -> String? {
            if let date = inputFormatter.date(from: string) {
                return outputFormatter.string(from: date)
            }
            return nil
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
        
        task = Task {
            do {
                guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/") else {
                    print("❌ URL inválida")
                    return
                }
                
                let encoder = JSONEncoder()
                let data = try encoder.encode(requestBody)
                
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
                    print("✅ Código de resposta: \(httpResponse.statusCode)")
                }
                
                if let responseBody = String(data: responseData, encoding: .utf8) {
                    print("📥 Resposta do servidor:")
                    print(responseBody)
                }
                
            } catch {
                print("❌ Erro na requisição: \(error.localizedDescription)")
            }
        }
    }
}
