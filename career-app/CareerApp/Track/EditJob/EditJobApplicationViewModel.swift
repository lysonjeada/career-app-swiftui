//
//  EditJobApplicationViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 30/06/25.
//

import Foundation

struct InterviewRequest: Codable {
    let company_name: String
    let job_title: String
    let job_seniority: String
    let last_interview_date: String?
    let next_interview_date: String?
    let location: String?
    let notes: String?
    let skills: [String]?
}

class EditJobApplicationViewModel: ObservableObject {
    private let service = JobApplicationService()

    enum State: Equatable {
        case loading
        case loaded
    }

    @Published private(set) var viewState: State = .loading

    private var task: Task<Void, Never>?

    
}
