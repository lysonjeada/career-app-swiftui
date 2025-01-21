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
    @State private var selectedTime: String = "Carga horária"
    @State private var selectedType: String = "Regime"
    @State private var text: String = ""
    @State var isSeniorityMenuSelected: Bool = false
    @State private var isSelectionModeActive = false
    @State private var selectedSkill: String? = nil
    @State private var showAlert = false
    @State var skills: [String] = ["swift", "cocoapods"]
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var addNewJob: () -> Void
    
    var jobType = [
        "Remoto",
        "Hibrido",
        "Presencial"
    ]
    
    var jobTime = [
        "Tempo integral",
        "Meio-periodo",
        "Estágio"
    ]
    
    var seniorityLevels = [
        "Intern",
        "Junior",
        "Mid-level",
        "Senior",
        "Lead",
        "Manager"
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
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
                                        ForEach(jobTime, id: \.self) { level in
                                            Button(action: {
                                                selectedTime = level
                                                if selectedTime.contains(level) {
    //                                                isSeniorityMenuSelected = true
                                                }
                                            }) {
                                                Text(level)
                                                    .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedTime)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                        }
                                        .foregroundColor(isSeniorityMenuSelected ? .persianBlue : .persianBlue.opacity(0.5))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 12)
                                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                                    }
                                    
                                    Menu {
                                        ForEach(jobType, id: \.self) { level in
                                            Button(action: {
                                                selectedType = level
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
                                            Text(selectedType)
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
                                HStack(alignment: .top) {
                                    Image("generate-image")
                                        .resizable()
                                        .padding(.leading, 12)
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                        .frame(maxWidth: 140, maxHeight: 100)
                                        
    //                                    .clipped()
                                        
                                    VStack(alignment: .leading) {
                                        Text("Você também pode gerar possíveis perguntas para as próximas entrevistas")
                                        
                                            .padding(.bottom)
                                        
                                        Button(action: {
                                            
                                        }) {
                                            Text("Gerar perguntas")
                                                .foregroundColor(Color.backgroundGray)
                                        }
                                    }
                                    
                                        
                                }
                                .padding(.top, 12)
                            }
                            Divider()
                        }
                        .navigationTitle("Add Job Application")
                        .navigationBarItems(trailing: Button("Cancel") {
                            UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
                        })
                    }
                }
            }
            .padding(.horizontal, 16)
            
            
            Button(action: {
                
            }) {
                VStack {
                    Text("Adicionar")
                        .bold()
                        .padding(.vertical, 12)
                        .foregroundColor(Color.white)
                        .background(Color.greenButton)
                        .frame(maxWidth: .infinity)
                }
                
                .frame(maxWidth: .infinity)
                
                .background(Color.greenButton)
                .background(Color.clear)
                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.greenButton, lineWidth: 1)
                                    )
                    
            }
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .frame(alignment: .bottom)
            .padding(.bottom, 8)
        }
        
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
                    // Adicione ação para adicionar nova skill aqui
                }) {
                    Image(systemName: "plus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.greenButton)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .padding(.trailing, 20)
                
                Button(action: {
                    isSelectionModeActive.toggle()
                }) {
                    Image(systemName: "minus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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
                            .background(isSelectionModeActive ? Color.redColor : Color.persianBlue)
                            .cornerRadius(12)
                            .onTapGesture {
                                if isSelectionModeActive {
                                    selectedSkill = skill
                                    showAlert = true
                                }
                            }
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Excluir Skill"),
                message: Text("Tem certeza de que deseja excluir \"\(selectedSkill ?? "")\"?"),
                primaryButton: .destructive(Text("Excluir")) {
                    if let skillToRemove = selectedSkill {
                        if let index = skills.firstIndex(of: skillToRemove) {
                            skills.remove(at: index)
                        }
                    }
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
    }
    
//    @ViewBuilder
//    private func addSkillView() -> some View {
//        VStack {
//            HStack {
//                Text("Skills")
//                    .font(.system(size: 24))
//                
//                Spacer()
//                
//                Button(action: {
//                    
//                }) {
//                    Image(systemName: "plus")
//                        .bold()
//                        .frame(width: 20, height: 20)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 12)
//                        .background(Color.greenButton)
//                        .foregroundColor(.white)
//                        .cornerRadius(24)
//                }
//                .padding(.trailing, 20)
//                
//                Button(action: {
//                    
//                }) {
//                    Image(systemName: "minus")
//                        .bold()
//                        .frame(width: 20, height: 20)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 12)
//                        .background(Color.redColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(24)
//                }
//            }
//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    ForEach(skills, id: \.self) { skill in
//                        Text(skill)
//                            .bold()
//                            .font(.system(size: 14))
//                            .foregroundColor(.white)
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 16)
//                            .background(Color.persianBlue)
//                            .cornerRadius(12)
//                    }
//                }
//                .padding(.vertical, 12)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.persianBlue, lineWidth: 1)
//                )
//            }
//        }
//        .padding(.top, 12)
//        .padding(.horizontal, 4)
//        
//    }
    
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
