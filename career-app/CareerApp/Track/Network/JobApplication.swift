//
//  JobApplication.swift
//  career-app
//

import Foundation

struct JobApplication: Identifiable, Equatable, Hashable {
    var id: String
    var company: String
    var level: String
    var role: String
    var lastInterview: String?
    var nextInterview: String?
    var technicalSkills: [String]

    init(
        id: String,
        company: String,
        level: String = "",
        role: String,
        lastInterview: String? = nil,
        nextInterview: String? = nil,
        technicalSkills: [String] = []
    ) {
        self.id = id
        self.company = company
        self.level = level
        self.role = role
        self.lastInterview = lastInterview
        self.nextInterview = nextInterview
        self.technicalSkills = technicalSkills
    }
}

extension JobApplication {
    init(from response: InterviewResponse) {
        self.init(
            id: response.id,
            company: response.company_name,
            level: response.job_seniority,
            role: response.job_title,
            lastInterview: response.last_interview_date?.toDate()?.toDayMonthString(),
            nextInterview: response.next_interview_date?.toDate()?.toDayMonthString(),
            technicalSkills: response.skills ?? []
        )
    }
}
