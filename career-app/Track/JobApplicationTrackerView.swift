//
//  JobApplicationTrackerView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 28/10/24.
//

import SwiftUI

struct JobApplication: Identifiable {
    var id = UUID()
    var company: String
    var level: String
    var role: String
    var lastInterview: String?
    var nextInterview: String?
    var technicalSkills: [String]
    var jobTitle: String?
    
    init(id: UUID = UUID(), company: String, level: String = "",role: String, lastInterview: String? = nil, nextInterview: String? = nil, technicalSkills: [String] = [], jobTitle: String? = nil) {
        self.id = id
        self.company = company
        self.level = level
        self.lastInterview = lastInterview
        self.role = role
        self.nextInterview = nextInterview
        self.technicalSkills = technicalSkills
        self.jobTitle = jobTitle
    }
}

struct JobApplicationTrackerView: View {
    @State private var jobApplications = [
        JobApplication(
            company: "PagBank",
            level: "Pleno",
            role: "iOS Developer",
            lastInterview: "12/04",
            nextInterview: "18/09",
            technicalSkills: [
                "Swift", "MVVM", "Clean Architecture",
                "Auto Layout", "Git", "CI/CD",
                "Scrum"
            ],
            jobTitle: "iOS Developer"
        )
    ]
    
    @StateObject private var viewModel = AddJobApplicationViewModel()
    
    @State private var newCompany = ""
    @State private var newLevel = ""
    @State private var newRole = ""
    @State private var newLastInterview = ""
    @State private var newNextInterview = ""
    @State private var newTechnicalSkills = ""
    @State private var showAddForm = false
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if viewModel.jobApplications.isEmpty {
                        VStack(alignment: .trailing) {
                            Text("Nada foi encontrado :(")
                                .bold()
                                .font(.system(size: 28))
                                .foregroundColor(.persianBlue)
                                .padding(.top, 49)
                            VStack(alignment: .trailing) {
                                Text("Parece que você ainda não adicionou\nnenhuma candidatura.\nAqui é onde você pode gerenciar\nsuas inscrições em vagas\nde forma organizada.")
                                    .foregroundColor(.persianBlue)
                                    .lineLimit(nil)
                                    .italic()
                                    .font(.system(size: 16))
                                    .padding(.top, 20)
                                    .padding(.bottom, 100)
                                    .frame(alignment: .trailing)
                                //                            .padding(.horizontal, 28)
                                VStack(alignment: .trailing) {
                                    Text("Clique aqui e adicione")
                                        .bold()
                                        .foregroundColor(.persianBlue)
                                        .font(.system(size: 16))
                                        .padding(.horizontal, 16)
                                        .padding(.top, 40)
                                        .shadow(color: .persianBlue, radius: 0.3, x: 0, y: 0)
                                        .offset(y: isAnimating ? -10 : 10)
                                        .animation(
                                            Animation.easeInOut(duration: 1.0)
                                                .repeatForever(autoreverses: true),
                                            value: isAnimating
                                        )
                                        .onAppear {
                                            isAnimating = true
                                        }
                                    Image("arrow-down")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 120, height: 160, alignment: .center)
                                        .clipped()
                                        .cornerRadius(10)
                                        .shadow(color: .persianBlue, radius: 1, x: 0, y: 0)
                                        .offset(y: isAnimating ? -10 : 10)
                                        .animation(
                                            Animation.easeInOut(duration: 1.0)
                                                .repeatForever(autoreverses: true),
                                            value: isAnimating
                                        )
                                        .onAppear {
                                            isAnimating = true
                                        }
                                    
                                }
                            }
                        }
                    }
                    ForEach(viewModel.jobApplications) { job in
                        JobApplicationCard(job: job)
                            .frame(alignment: .top)
                            .padding(.top, 16)
                            .padding(.horizontal, 12)
                    }
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            showAddForm.toggle()
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.trash")
                                    .bold()
                                    .foregroundStyle(.white)
                                Text("Apagar")
                                    .bold()
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                
                            }
                            .padding(.horizontal, 12)
                            .background(Color.redColor)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showAddForm.toggle()
                        }) {
                            if viewModel.jobApplications.isEmpty {
                                VStack {
                                    HStack {
                                        Image(systemName: "plus")
                                            .bold()
                                            .foregroundStyle(.white)
                                        Text("Adicionar")
                                            .bold()
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        
                                    }
                                    .padding(.horizontal, 12)
                                    .background(Color(red: 0, green: 94, blue: 66))
                                    .cornerRadius(10)
                                }
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.persianBlue, lineWidth: 3)
                                        .shadow(color: .persianBlue, radius: 1, x: 0, y: 0)
                                )
                                
                            } else {
                                HStack {
                                    Image(systemName: "plus")
                                        .bold()
                                        .foregroundStyle(.white)
                                    Text("Adicionar")
                                        .bold()
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    
                                }
                                .padding(.horizontal, 12)
                                .background(Color(red: 0, green: 94, blue: 66))
                                .cornerRadius(10)
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                }
                .onAppear {
                    viewModel.fetchJobApplications()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Candidaturas")
                            .bold()
                            .font(.system(size: 28))
                            .foregroundColor(.persianBlue)
                    }
                }
                
                .sheet(isPresented: $showAddForm) {
                    AddJobApplicationForm(
                        newCompany: $newCompany,
                        newLevel: $newLevel,
                        newLastInterview: $newLastInterview,
                        newNextInterview: $newNextInterview,
                        newTechnicalSkills: $newTechnicalSkills
                    )
                }
            }
        }
    }
    
    // Função para adicionar um novo trabalho
    func addNewJob() {
        let technicalSkillsArray = newTechnicalSkills
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let newJob = JobApplication(
            company: newCompany,
            level: newLevel,
            role: newRole,
            lastInterview: newLastInterview.isEmpty ? nil : newLastInterview,
            nextInterview: newNextInterview.isEmpty ? nil : newNextInterview,
            technicalSkills: technicalSkillsArray,
            jobTitle: nil
        )
        jobApplications.append(newJob)
        clearForm()
    }
    
    // Limpar os inputs após o cadastro
    func clearForm() {
        newCompany = ""
        newLevel = ""
        newLastInterview = ""
        newNextInterview = ""
        newTechnicalSkills = ""
    }
}


struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        JobApplicationTrackerView()
    }
}
