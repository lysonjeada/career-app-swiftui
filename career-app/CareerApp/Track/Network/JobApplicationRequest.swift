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
