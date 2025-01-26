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
    @State private var skills: [String] = []
    @State private var showSkillSheet: Bool = false
    @State private var isSelectionModeActive: Bool = false
    @StateObject private var viewModel = AddJobApplicationViewModel()
    
    let jobType = ["Remoto", "Híbrido", "Presencial"]
    let jobTime = ["Tempo integral", "Meio-período", "Estágio"]
    let seniorityLevels = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager"]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Adicione senioridade e cargo")
                            .font(.system(size: 24))
                            .padding(.bottom, 4)
                        
                        HStack {
                            testFieldTest(placeholder: "Senioridade", value: $newLevel)
                            menuField(selectedItem: $selectedSeniority, options: seniorityLevels, placeholder: "Selecione")
                        }
                        
                        HStack {
                            testFieldTest(placeholder: "Cargo", value: $newLevel)
                            menuField(selectedItem: $selectedRole, options: seniorityLevels, placeholder: "Selecione")
                        }
                        
                        Divider().padding(.vertical)
                        
                        Text("Sobre a empresa")
                            .font(.system(size: 24))
                        
                        testFieldTest(placeholder: "Empresa", value: $newCompany)
                        
                        Divider().padding(.vertical)
                        
                        addSkillView()
                        
                        Divider().padding(.vertical)
                        
                        
                        
                        VStack(alignment: .leading) {
                            Text("Datas")
                                .font(.system(size: 24))
                            
                            DateInputField(
                                dateString: $newNextInterview, placeholder: "Próxima entrevista"
                            )
                            DateInputField(
                                dateString: $newLastInterview, placeholder: "Entrevista passada"
                            )
                        }
                        
                        Divider().padding(.vertical)
                        
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
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.addJobApplication(
                    company: newCompany,
                    level: newLevel,
                    lastInterview: newLastInterview,
                    nextInterview: newNextInterview,
                    technicalSkills: skills
                )
            }) {
                Text("Adicionar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.persianBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Adicionar Candidatura")
    }
    
    @ViewBuilder
    private func testFieldTest(placeholder: String, value: Binding<String>) -> some View {
        TextField(placeholder, text: value)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.persianBlue))
    }
    
    @ViewBuilder
    private func menuField(selectedItem: Binding<String>, options: [String], placeholder: String) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selectedItem.wrappedValue = option
                }
            }
        } label: {
            HStack {
                Text(selectedItem.wrappedValue.isEmpty ? placeholder : selectedItem.wrappedValue)
                    .foregroundColor(Color.persianBlue)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.persianBlue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.persianBlue))
        }
    }
    
    @ViewBuilder
    private func addSkillView() -> some View {
        VStack {
            HStack {
                Text("Skills")
                    .font(.system(size: 24))
                
                Spacer()
                
                Button(action: {
                    showSkillSheet.toggle()
                }) {
                    Image(systemName: "plus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(24)
                }
                .padding(.trailing, 4)

                Button(action: {
                    isSelectionModeActive.toggle()
                }) {
                    Image(systemName: "minus")
                        .bold()
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .foregroundColor(.persianBlue)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.persianBlue, lineWidth: 2) // Adiciona a borda azul
                        )
                }

//                Button(action: {
//                    showSkillSheet.toggle()
//                }) {
//                    Image(systemName: "plus")
//                        .bold()
//                        .frame(width: 20, height: 20)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(Color.persianBlue)
//                        .foregroundColor(.white)
//                        .cornerRadius(24)
//                }
//                .padding(.trailing, 20)
//                
//                Button(action: {
//                    isSelectionModeActive.toggle()
//                }) {
//                    Image(systemName: "minus")
//                        .bold()
//                        .frame(width: 20, height: 20)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .background(Color.redColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(24)
//                }
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(skills.prefix(5), id: \.self) { skill in
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
                                skills.removeAll(where: { $0 == skill })
                            }
                        }
                }
            }
            
        }
        .padding(.top, 12)
        .sheet(isPresented: $showSkillSheet) {
            SkillSelectionView(selectedSkills: $skills)
        }
    }
}

struct AddJobApplicationForm_Previews: PreviewProvider {
    @State static private var company = ""
    @State static private var level = ""
    @State static private var lastInterview = ""
    @State static private var nextInterview = ""
    @State static private var technicalSkills = ""
    
    static var previews: some View {
        NavigationView {
            AddJobApplicationForm(
                newCompany: $company,
                newLevel: $level,
                newLastInterview: $lastInterview,
                newNextInterview: $nextInterview,
                newTechnicalSkills: $technicalSkills
            )
        }
        .previewDevice("iPhone 14")
        .previewDisplayName("Add Job Application Form")
    }
}

