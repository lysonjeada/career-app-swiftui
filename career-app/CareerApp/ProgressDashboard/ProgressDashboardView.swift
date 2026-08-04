//
//  ProgressDashboardView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import Charts
import SwiftUI

struct ProgressDashboardView: View {

    let dashboard: ProgressDashboard
    let selectedMonths: Int

    let changePeriodAction: (Int) -> Void
    let refreshAction: () async -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DashboardPeriodPicker(
                    selectedMonths: selectedMonths,
                    changeAction:
                        changePeriodAction
                )

                DashboardSummaryGrid(
                    summary: dashboard.summary
                )

                MonthlyEvolutionCard(
                    items:
                        dashboard.monthlyEvolution
                )

                TopSkillsCard(
                    skills: dashboard.topSkills
                )

                ActiveCompaniesCard(
                    companies:
                        dashboard.activeCompanies
                )
            }
            .padding()
        }
        .refreshable {
            await refreshAction()
        }
    }
}
