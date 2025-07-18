//
//  EditJobApplicationView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/06/25.
//

import SwiftUI

struct EditJobApplicationView: View {
    let job: JobApplication
    @StateObject var coordinator: Coordinator
    
    @State private var company: String = ""
    @State private var role: String = ""
    @State private var level: String = ""
    @State private var lastInterview: String = ""
    @State private var nextInterview: String = ""
    @State private var technicalSkills: [String] = []
    
    @State private var selectedSeniority: String = "Senioridade"
    @State private var selectedRole: String = "Cargo"
    @State private var selectedTime: String = "Carga horária"
    @State private var selectedType: String = "Regime"
    @State private var skills: [String] = []
    @State private var showSkillSheet: Bool = false
    @State private var isSelectionModeActive: Bool = false
    @StateObject var viewModel: JobApplicationTrackerListViewModel
    
    let jobType = ["Remoto", "Híbrido", "Presencial"]
    let jobTime = ["Tempo integral", "Meio-período", "Estágio"]
    let seniorityLevels = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager"]
    let roleOptions = ["iOS Developer", "Backend", "Frontend", "QA", "Tech Lead"]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
//                        Text("Edite senioridade e cargo")
//                            .font(.system(size: 24))
//                            .padding(.bottom, 4)
//                            .padding(.top, 16)
                        
                        applicationTextField(title: "Nível", placeholder: "Senioridade", value: $level)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        
                        applicationTextField(title: "Título", placeholder: "Cargo", value: $role)

                        
                        Divider().padding(.vertical, 16)
                        
//                        Text("Sobre a empresa")
//                            .font(.system(size: 24))
                        
                        applicationTextField(title: "Empresa", placeholder: "Nome da empresa", value: $company)
                        
                        Divider().padding(.vertical, 16)
                        
                        addSkillView()
                        
                        Divider().padding(.vertical)
                        
                        
                        VStack(alignment: .leading) {
                            Text("Datas")
                                .font(.system(size: 24))
                            
                            DateInputField(
                                dateString: $nextInterview, placeholder: "Próxima entrevista"
                            )
                            DateInputField(
                                dateString: $lastInterview, placeholder: "Entrevista passada"
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
                viewModel.editJob(
                    id: job.id,
                    company: company,
                    role: role,
                    level: level,
                    lastInterview: lastInterview,
                    nextInterview: nextInterview,
                    technicalSkills: technicalSkills
                )
                coordinator.pop()
            }) {
                Text("Atualizar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.persianBlue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .onAppear {
            company = job.company
            level = job.level
            role = job.role
            lastInterview = job.lastInterview ?? ""
            nextInterview = job.nextInterview ?? ""
            technicalSkills = job.technicalSkills
        }
        .navigationConfig(title: "Editar candidatura", backAction: { coordinator.pop() })
        .navigationTitle("Atualizar Candidatura")
    }
    
    @ViewBuilder
    private func applicationTextField(title: String = "", placeholder: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.persianBlue)
            TextField(placeholder, text: value)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.persianBlue))
        }
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
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(technicalSkills.prefix(5), id: \.self) { skill in
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
