//
//  SkillSelectionView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 25/01/25.
//

import SwiftUI

struct SkillSelectionView: View {
    @Binding var selectedSkills: [String]
    @State private var allSkills = ["Swift", "Kotlin", "JavaScript", "TypeScript", "Python", "Docker", "Kubernetes", "React", "Node.js", "CI/CD", "AWS", "Azure"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allSkills, id: \.self) { skill in
                    Button(action: {
                        if !selectedSkills.contains(skill) {
                            selectedSkills.append(skill)
                        }
                    }) {
                        HStack {
                            Text(skill)
                            Spacer()
                            if selectedSkills.contains(skill) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Selecione Skills")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Fecha a view
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
                    }) {
                        Image(systemName: "xmark") // Ícone "X" do SF Symbols
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.persianBlue)
                    }
                }
            }
        }
    }
}
