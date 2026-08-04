//
//  ProgressDashboardView+Preview.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

#if DEBUG

import SwiftUI

private final class ProgressDashboardServiceMock:
    ProgressDashboardServiceProtocol {

    func fetchProgressDashboard(
        months: Int
    ) async throws -> ProgressDashboard {
        .previewMock
    }
}

private extension ProgressDashboard {

    static let previewMock = ProgressDashboard(
        summary: DashboardSummary(
            totalApplications: 42,
            completedInterviews: 18,
            scheduledInterviews: 4,
            responseRate: 57,
            offersCount: 3,
            activeCompaniesCount: 8
        ),
        topSkills: [
            DashboardSkill(
                skill: "Swift",
                count: 24,
                percentage: 57
            ),
            DashboardSkill(
                skill: "SwiftUI",
                count: 19,
                percentage: 45
            ),
            DashboardSkill(
                skill: "UIKit",
                count: 16,
                percentage: 38
            ),
            DashboardSkill(
                skill: "MVVM",
                count: 14,
                percentage: 33
            ),
            DashboardSkill(
                skill: "XCTest",
                count: 11,
                percentage: 26
            )
        ],
        activeCompanies: [
            DashboardCompany(
                companyName: "TechStep",
                activeProcesses: 2,
                latestActivity: Date()
            ),
            DashboardCompany(
                companyName: "Mercado Mobile",
                activeProcesses: 1,
                latestActivity: Date()
            ),
            DashboardCompany(
                companyName: "Swift Bank",
                activeProcesses: 1,
                latestActivity: Date()
            )
        ],
        monthlyEvolution: [
            DashboardMonthlyProgress(
                month: "2026-02",
                label: "Fev/26",
                applications: 4,
                interviews: 1,
                offers: 0
            ),
            DashboardMonthlyProgress(
                month: "2026-03",
                label: "Mar/26",
                applications: 7,
                interviews: 3,
                offers: 0
            ),
            DashboardMonthlyProgress(
                month: "2026-04",
                label: "Abr/26",
                applications: 5,
                interviews: 4,
                offers: 1
            ),
            DashboardMonthlyProgress(
                month: "2026-05",
                label: "Mai/26",
                applications: 9,
                interviews: 5,
                offers: 0
            ),
            DashboardMonthlyProgress(
                month: "2026-06",
                label: "Jun/26",
                applications: 8,
                interviews: 3,
                offers: 1
            ),
            DashboardMonthlyProgress(
                month: "2026-07",
                label: "Jul/26",
                applications: 9,
                interviews: 2,
                offers: 1
            )
        ]
    )
}

#Preview("Dashboard — Light") {
    NavigationStack {
        ProgressDashboardFlowView(
            service:
                ProgressDashboardServiceMock()
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Dashboard — Dark") {
    NavigationStack {
        ProgressDashboardFlowView(
            service:
                ProgressDashboardServiceMock()
        )
    }
    .preferredColorScheme(.dark)
}

#endif
