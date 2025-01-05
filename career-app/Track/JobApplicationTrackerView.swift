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
            nextInterview: "18/09/2024",
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
                            .padding(.top)
                    }
                Spacer()
                
                Button(action: {
                    showAddForm.toggle()
                }) {
                    Text("Add New Job Application")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Job Applications")
            .sheet(isPresented: $showAddForm) {
                AddJobApplicationForm(
                    newCompany: $newCompany,
                    newLevel: $newLevel,
                    newLastInterview: $newLastInterview,
                    newNextInterview: $newNextInterview,
                    newTechnicalSkills: $newTechnicalSkills,
                    addNewJob: addNewJob
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

struct JobApplicationCard: View {
    var job: JobApplication
    
    let gridColumns = [
            GridItem(.adaptive(minimum: 80), spacing: 4),
            GridItem(.adaptive(minimum: 80), spacing: 4),
            GridItem(.adaptive(minimum: 80), spacing: 4)
        ]

    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(job.company)
                        .font(.headline)
                    Spacer()
                    Text(job.level)
                        .font(.subheadline)
                    if let lastInterview = job.lastInterview {
                        Text("Last: \(lastInterview)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("Skills")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 8) {
                    ForEach(job.technicalSkills, id: \.self) { skill in
                        Text(skill)
                            .font(.caption)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            Divider()
        }
}

struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        JobApplicationTrackerView()
    }
}
