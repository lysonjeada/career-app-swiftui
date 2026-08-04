//
//  MonthlyEvolutionCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI
import Charts

struct MonthlyEvolutionCard: View {
    let items: [DashboardMonthlyProgress]

    var body: some View {
        DashboardSectionCard(
            title: "Evolução por mês",
            icon: "chart.xyaxis.line"
        ) {
            if items.isEmpty {
                DashboardEmptyContent(
                    text: "Ainda não há dados mensais."
                )
            } else {
                Chart(items) { item in
                    BarMark(
                        x: .value(
                            "Mês",
                            item.label
                        ),
                        y: .value(
                            "Candidaturas",
                            item.applications
                        )
                    )
                    .foregroundStyle(
                        by: .value(
                            "Tipo",
                            "Candidaturas"
                        )
                    )

                    LineMark(
                        x: .value(
                            "Mês",
                            item.label
                        ),
                        y: .value(
                            "Entrevistas",
                            item.interviews
                        )
                    )
                    .foregroundStyle(
                        by: .value(
                            "Tipo",
                            "Entrevistas"
                        )
                    )
                    .symbol(.circle)

                    PointMark(
                        x: .value(
                            "Mês",
                            item.label
                        ),
                        y: .value(
                            "Ofertas",
                            item.offers
                        )
                    )
                    .foregroundStyle(
                        by: .value(
                            "Tipo",
                            "Ofertas"
                        )
                    )
                    .symbol(.diamond)
                }
                .chartYAxis {
                    AxisMarks(
                        position: .leading
                    )
                }
                .frame(height: 230)
            }
        }
    }
}
