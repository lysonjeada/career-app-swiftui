//
//  JobApplicationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/01/25.
//

import Foundation

class AddJobApplicationViewModel: ObservableObject {
    private let service = JobApplicationService()
    @Published var jobApplications: [JobApplication] = []
    
    func addJobApplication(company: String, level: String, lastInterview: String, nextInterview: String, technicalSkills: [String]) {
        let request = JobApplicationRequest(
            company: company,
            role: "",
            level: level,
            lastInterview: lastInterview.isEmpty ? nil : lastInterview,
            nextInterview: nextInterview.isEmpty ? nil : nextInterview,
            technicalSkills: technicalSkills
        )
        
        service.createJobApplication(request) { result in
            switch result {
            case .success:
                print("Job application created successfully!")
            case .failure(let error):
                print("Failed to create job application: \(error)")
            }
        }
    }
    
    func fetchJobApplications() {
            service.fetchJobApplications { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let applications):
                        self.jobApplications = applications.map { app in
                            JobApplication(
                                company: app.company,
                                level: app.level,
                                role: app.role,
                                lastInterview: app.lastInterview,
                                nextInterview: app.nextInterview,
                                technicalSkills: app.technicalSkills
                            )
                        }
                    case .failure(let error):
                        print("Failed to fetch job applications: \(error)")
                    }
                }
            }
        }
}
