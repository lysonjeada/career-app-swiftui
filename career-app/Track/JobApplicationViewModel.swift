//
//  JobApplicationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/01/25.
//

import Foundation

class AddJobApplicationViewModel: ObservableObject {
    private let service = JobApplicationService()
    
    func addJobApplication(company: String, level: String, lastInterview: String, nextInterview: String, technicalSkills: [String]) {
        let request = JobApplicationRequest(
            company: company,
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
}
