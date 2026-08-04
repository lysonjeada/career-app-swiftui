//
//  ProgressDashboardModels.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import Foundation

struct ProgressDashboard:
    Decodable,
    Equatable {

    let summary: DashboardSummary
    let topSkills: [DashboardSkill]
    let activeCompanies: [DashboardCompany]
    let monthlyEvolution: [DashboardMonthlyProgress]
}

struct DashboardSummary:
    Decodable,
    Equatable {

    let totalApplications: Int
    let completedInterviews: Int
    let scheduledInterviews: Int
    let responseRate: Double
    let offersCount: Int
    let activeCompaniesCount: Int
}

struct DashboardSkill:
    Decodable,
    Identifiable,
    Equatable {

    var id: String {
        skill
    }

    let skill: String
    let count: Int
    let percentage: Double
}

struct DashboardCompany:
    Decodable,
    Identifiable,
    Equatable {

    var id: String {
        companyName
    }

    let companyName: String
    let activeProcesses: Int
    let latestActivity: Date?
}

struct DashboardMonthlyProgress:
    Decodable,
    Identifiable,
    Equatable {

    var id: String {
        month
    }

    let month: String
    let label: String
    let applications: Int
    let interviews: Int
    let offers: Int
}
