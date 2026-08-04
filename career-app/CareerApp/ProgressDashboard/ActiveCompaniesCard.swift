//
//  ActiveCompaniesCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI

struct ActiveCompaniesCard: View {
    let companies: [DashboardCompany]

    var body: some View {
        DashboardSectionCard(
            title: "Processos ativos",
            icon: "building.2.fill"
        ) {
            if companies.isEmpty {
                DashboardEmptyContent(
                    text: "Nenhum processo ativo."
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(
                        Array(
                            companies.prefix(6)
                        )
                    ) { company in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        Color.persianBlue
                                            .opacity(0.12)
                                    )
                                    .frame(
                                        width: 42,
                                        height: 42
                                    )

                                Text(
                                    company.companyName
                                        .prefix(1)
                                        .uppercased()
                                )
                                .bold()
                                .foregroundColor(
                                    .persianBlue
                                )
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {
                                Text(
                                    company.companyName
                                )
                                .font(.subheadline)
                                .fontWeight(.semibold)

                                if let latestActivity =
                                        company.latestActivity {
                                    Text(
                                        latestActivity.formatted(
                                            date: .abbreviated,
                                            time: .omitted
                                        )
                                    )
                                    .font(.caption)
                                    .foregroundStyle(
                                        .secondary
                                    )
                                }
                            }

                            Spacer()

                            Text(
                                "\(company.activeProcesses)"
                            )
                            .font(.headline)
                            .foregroundColor(
                                .persianBlue
                            )
                        }
                        .padding(.vertical, 12)

                        if company.id !=
                            companies.prefix(6).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
