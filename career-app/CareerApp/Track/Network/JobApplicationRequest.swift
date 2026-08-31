//
//  JobApplicationRequest.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

struct JobApplicationRequest: Codable {
    let company: String
    let role: String
    let level: String
    let lastInterview: String?
    let nextInterview: String?
    let technicalSkills: [String]
}

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
