//
//  ProgressDashboardServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class ProgressDashboardServiceMock: ProgressDashboardServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedMonths: [Int] = []
    private(set) var callCount = 0

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func fetchProgressDashboard(months: Int) async throws -> ProgressDashboard {
        callCount += 1
        receivedMonths.append(months)

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        let dto: ProgressDashboardFixtureDTO = try JSONLoader.load("progress-dashboard-response")
        return dto.toDomain()
    }
}

private struct ProgressDashboardFixtureDTO: Decodable {
    let summary: DashboardSummary
    let topSkills: [DashboardSkill]
    let activeCompanies: [DashboardCompanyFixtureDTO]
    let monthlyEvolution: [DashboardMonthlyProgress]

    func toDomain() -> ProgressDashboard {
        ProgressDashboard(
            summary: summary,
            topSkills: topSkills,
            activeCompanies: activeCompanies.map { $0.toDomain() },
            monthlyEvolution: monthlyEvolution
        )
    }
}

private struct DashboardCompanyFixtureDTO: Decodable {
    let companyName: String
    let activeProcesses: Int
    let latestActivity: String?

    func toDomain() -> DashboardCompany {
        DashboardCompany(
            companyName: companyName,
            activeProcesses: activeProcesses,
            latestActivity: latestActivity.flatMap {
                ISO8601DateFormatter().date(from: $0)
            }
        )
    }
}
