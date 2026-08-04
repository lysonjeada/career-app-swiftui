//
//  DashboardSummaryGrid.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI

struct DashboardSummaryGrid: View {
    let summary: DashboardSummary

    private let columns = [
        GridItem(
            .flexible(),
            spacing: 12
        ),
        GridItem(
            .flexible(),
            spacing: 12
        ),
    ]

    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: 12
        ) {
            DashboardMetricCard(
                title: "Candidaturas",
                value: String(
                    summary.totalApplications
                ),
                icon: "doc.text.fill"
            )

            DashboardMetricCard(
                title: "Realizadas",
                value: String(
                    summary.completedInterviews
                ),
                icon: "checkmark.circle.fill"
            )

            DashboardMetricCard(
                title: "Agendadas",
                value: String(
                    summary.scheduledInterviews
                ),
                icon: "calendar.badge.clock"
            )

            DashboardMetricCard(
                title: "Taxa de retorno",
                value: String(
                    format: "%.0f%%",
                    summary.responseRate
                ),
                icon: "arrow.turn.up.right"
            )

            DashboardMetricCard(
                title: "Ofertas",
                value: String(
                    summary.offersCount
                ),
                icon: "star.fill"
            )

            DashboardMetricCard(
                title: "Empresas ativas",
                value: String(
                    summary.activeCompaniesCount
                ),
                icon: "building.2.fill"
            )
        }
    }
}

private struct DashboardMetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.persianBlue)

            Text(value)
                .font(.system(
                    size: 28,
                    weight: .bold
                ))
                .foregroundStyle(.primary)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 120,
            alignment: .leading
        )
        .padding()
        .background(
            Color(
                uiColor:
                    .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
