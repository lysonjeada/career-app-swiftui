//
//  SkillSelectionView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/01/25.
//

import SwiftUI

struct SkillSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedSkills: [String]

    let availableSkills = [
        "Swift",
        "SwiftUI",
        "UIKit",
        "Combine",
        "Core Data",
        "Git",
        "REST API",
        "Unit Tests",
        "Kotlin",
        "JavaScript",
        "TypeScript",
        "Python",
        "Docker",
        "Kubernetes", 
        "React",
        "Node.js",
        "CI/CD",
        "AWS",
        "Azure",
        "Java",
        "SQL"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 110))
                    ],
                    spacing: 12
                ) {
                    ForEach(availableSkills, id: \.self) { skill in
                        Button {
                            toggleSkill(skill)
                        } label: {
                            HStack {
                                Text(skill)
                                    .font(.system(size: 14))
                                    .bold()

                                if isSelected(skill) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .foregroundColor(
                                isSelected(skill)
                                    ? .white
                                    : .persianBlue
                            )
                            .background(
                                isSelected(skill)
                                    ? Color.persianBlue
                                    : Color.clear
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color.persianBlue,
                                        lineWidth: 1
                                    )
                            }
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Selecionar skills")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluir") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleSkill(_ skill: String) {
        if let index = selectedSkills.firstIndex(
            where: {
                $0.caseInsensitiveCompare(skill) == .orderedSame
            }
        ) {
            selectedSkills.remove(at: index)
        } else {
            selectedSkills.append(skill)
        }
    }

    private func isSelected(_ skill: String) -> Bool {
        selectedSkills.contains {
            $0.caseInsensitiveCompare(skill) == .orderedSame
        }
    }
}
