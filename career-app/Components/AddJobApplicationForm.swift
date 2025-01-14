//
//  AddJobApplicationForm.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct AddJobApplicationForm: View {
    @Binding var newCompany: String
    @Binding var newLevel: String
    @Binding var newLastInterview: String
    @Binding var newNextInterview: String
    @Binding var newTechnicalSkills: String
    @State private var selectedSeniority: String = "Senioridade"
    @State private var selectedRole: String = "Cargo"
    @State private var text: String = ""
    @State var isSeniorityMenuSelected: Bool = false
    var skills: [String] = ["swift", "cocoapods"]
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var addNewJob: () -> Void
    
    var seniorityLevels = [
        "Intern",
        "Junior",
        "Mid-level",
        "Senior",
        "Lead",
        "Manager"
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Adicione senioridade e cargo")
                                .font(.system(size: 24))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .padding(.bottom, 4)
                            
                            Text("Apenas digite ou selecione cada um, não é preciso preencher os dois")
                                .font(.system(size: 16))
                                .foregroundStyle(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                testFieldTest(placeholder: "Senioridade", value: $newLevel)
                                
                                
                                Menu {
                                    ForEach(seniorityLevels, id: \.self) { level in
                                        Button(action: {
                                            selectedSeniority = level
                                            if selectedSeniority.contains(level) {
                                                isSeniorityMenuSelected = true
                                            }
                                        }) {
                                            Text(level)
                                                .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedSeniority)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                                }
                            }
                            
                            HStack {
                                testFieldTest(placeholder: "Cargo", value: $newLevel)
                                
                                
                                Menu {
                                    ForEach(seniorityLevels, id: \.self) { level in
                                        Button(action: {
                                            selectedSeniority = level
                                            if selectedSeniority.contains(level) {
                                                isSeniorityMenuSelected = true
                                            }
                                        }) {
                                            Text(level)
                                                .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedRole)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                                }
                            }
                        }
                        Divider()
                        .padding(.bottom, 12)
                        
                        VStack(alignment: .leading) {
                            Text("Sobre a empresa")
                                .font(.system(size: 24))
                            testFieldTest(placeholder: "Empresa", value: $newCompany)
                                .padding(.bottom, 12)
                            Text("Complementares opcionais")
                                .font(.system(size: 16))
                                .foregroundStyle(.gray)
                            
                            HStack {
                                Menu {
                                    ForEach(seniorityLevels, id: \.self) { level in
                                        Button(action: {
                                            selectedSeniority = level
                                            if selectedSeniority.contains(level) {
                                                isSeniorityMenuSelected = true
                                            }
                                        }) {
                                            Text(level)
                                                .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedSeniority)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                                }
                                
                                Menu {
                                    ForEach(seniorityLevels, id: \.self) { level in
                                        Button(action: {
                                            selectedSeniority = level
                                            if selectedSeniority.contains(level) {
                                                isSeniorityMenuSelected = true
                                            }
                                        }) {
                                            Text(level)
                                                .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedSeniority)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 12)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                                }
                            }
                        }
                        
                        Divider()
                        
                        
                        addSkillView()
                        Divider()
                        .padding(.bottom, 12)

                        VStack(alignment: .leading) {
                            Text("Datas")
                                .font(.system(size: 24))
                            
                            DateInputField(placeholder: "Próxima entrevista")
                            DateInputField(placeholder: "Entrevista passada")
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Complementares")
                            
                            
                        }
                    }
                    .navigationTitle("Add Job Application")
                    .navigationBarItems(trailing: Button("Cancel") {
                        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
                    })
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func testFieldTest(placeholder: String,
                               value: Binding<String>) -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.persianBlue.opacity(0.5))
                    .padding(.leading)
            }
            
            TextField("", text: value)
                .padding(.vertical, 12)
                .foregroundColor(.persianBlue) // Cor do texto digitado
        }
        
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.persianBlue, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func addSkillView() -> some View {
        VStack {
            HStack {
                Text("Skills")
                    .font(.system(size: 24))
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "plus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.greenButton)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .padding(.trailing, 20)
                
                Button(action: {
                    
                }) {
                    Image(systemName: "minus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.redColor)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
            }
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(skills, id: \.self) { skill in
                        Text(skill)
                            .bold()
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.persianBlue)
                            .cornerRadius(12)
                    }
                }
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.persianBlue, lineWidth: 1)
                )
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 4)
        
    }
    
    private func menuTextColor(for level: String) -> Color {
            seniorityLevels.contains(level) ? .persianBlue : .persianBlue.opacity(0.5)
        }
        
        private func menuBorderColor(for level: String) -> Color {
            seniorityLevels.contains(level) ? Color.persianBlue : Color.persianBlue.opacity(0.5)
        }
}

#Preview {
    AddJobApplicationForm(newCompany: .constant(""), newLevel: .constant(""), newLastInterview: .constant(""), newNextInterview: .constant(""), newTechnicalSkills: .constant(""), skills: ["Swift", "Cocoapods", "Firebase", "SPM", "New relic", "Analytics"], addNewJob: {})
}
