//
//  TopSkillsCard.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import SwiftUI

struct TopSkillsCard: View {
    let skills: [DashboardSkill]

    var body: some View {
        DashboardSectionCard(
            title: "Skills mais exigidas",
            icon: "hammer.fill"
        ) {
            if skills.isEmpty {
                DashboardEmptyContent(
                    text: "Nenhuma skill cadastrada."
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(skills) { skill in
                        VStack(spacing: 7) {
                            HStack {
                                Text(skill.skill)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()

                                Text(
                                    "\(skill.count) vagas"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            ProgressView(
                                value:
                                    skill.percentage,
                                total: 100
                            )
                            .tint(.persianBlue)

                            Text(
                                String(
                                    format: "%.0f%% das candidaturas",
                                    skill.percentage
                                )
                            )
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                        }
                    }
                }
            }
        }
    }
}
