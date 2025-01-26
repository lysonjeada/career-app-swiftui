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
    var lastInterview: String?
    var nextInterview: String?
    var technicalSkills: [String]
    var jobTitle: String?
    
    init(id: UUID = UUID(), company: String, level: String = "", lastInterview: String? = nil, nextInterview: String? = nil, technicalSkills: [String] = [], jobTitle: String? = nil) {
        self.id = id
        self.company = company
        self.level = level
        self.lastInterview = lastInterview
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
    
    // Inputs para cadastrar novo job
    @State private var newCompany = ""
    @State private var newLevel = ""
    @State private var newLastInterview = ""
    @State private var newNextInterview = ""
    @State private var newTechnicalSkills = ""
    @State private var showAddForm = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                ForEach(jobApplications) { job in
                    JobApplicationCard(job: job)
                        .frame(alignment: .top)
                        .padding(.top, 16)
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
                .padding(.horizontal)
                
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
    
    // Função para adicionar um novo trabalho
    func addNewJob() {
        let technicalSkillsArray = newTechnicalSkills
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let newJob = JobApplication(
            company: newCompany,
            level: newLevel,
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
