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
    var technicalSkills: String
    var jobTitle: String?
    
    // Inicializador único com valores padrão
    init(id: UUID = UUID(), company: String, level: String = "", lastInterview: String? = nil, nextInterview: String?, technicalSkills: String = "", jobTitle: String?) {
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
        JobApplication(company: "PagBank", level: "Pleno", lastInterview: nil, nextInterview: "18/09/2024", technicalSkills: """
            Experiência com aplicativos em iOS nativo.
            Experiência em Apple Design Guidelines.
            Experiência com auto layout e diferentes resoluções de tela.
            Experiência com GIT.
            Experiência em realizar testes, CodeReview e integração contínua.
            Experiência com Swift.
            Experiência com boas práticas de desenvolvimento (SOLID, KISS e DRY).
            Experiência com MVVM, Clean Architecture.
            Conhecimento em bibliotecas comuns do iOS.
            Desejável:
            Conhecimento em CI/CD, Bluetooth API, Core Data.
            Experiência em automação com fastlane.
            Experiência em Scrum, Kanban e Rx.
            """,
                       jobTitle: ""
                      )
    ]
    
    // New Job Application Inputs
    @State private var newCompany = ""
    @State private var newLevel = ""
    @State private var newLastInterview = ""
    @State private var newNextInterview = ""
    @State private var newTechnicalSkills = ""
    
    @State private var showAddForm = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(jobApplications) { job in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Empresa:")
                                    .font(.headline)
                                Text(job.company)
                                    .font(.subheadline)
                            }
                            HStack {
                                Text("Nível:")
                                    .font(.headline)
                                Text(job.level)
                                    .font(.subheadline)
                            }
                            HStack {
                                Text("Última entrevista:")
                                    .font(.headline)
                                Text(job.lastInterview ?? "N/A")
                                    .font(.subheadline)
                            }
                            HStack {
                                Text("Próxima entrevista:")
                                    .font(.headline)
                                Text(job.nextInterview ?? "N/A")
                                    .font(.subheadline)
                            }
                            HStack {
                                Text("Skills técnicas:")
                                    .font(.headline)
                                Spacer()
                            }
                            Text(job.technicalSkills)
                                .font(.subheadline)
                                .padding(.leading, 10)
                        }
                        .padding()
                    }
                }
                
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
    
    // Function to add a new job
    func addNewJob() {
        let newJob = JobApplication(company: newCompany, level: newLevel, lastInterview: newLastInterview, nextInterview: newNextInterview, technicalSkills: newTechnicalSkills, jobTitle: "")
        jobApplications.append(newJob)
        clearForm()
    }
    
    // Clear the form after submission
    func clearForm() {
        newCompany = ""
        newLevel = ""
        newLastInterview = ""
        newNextInterview = ""
        newTechnicalSkills = ""
    }
}

struct AddJobApplicationForm: View {
    @Binding var newCompany: String
    @Binding var newLevel: String
    @Binding var newLastInterview: String
    @Binding var newNextInterview: String
    @Binding var newTechnicalSkills: String
    
    var addNewJob: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company Details")) {
                    TextField("Company", text: $newCompany)
                    TextField("Job Level", text: $newLevel)
                }
                
                Section(header: Text("Interview Dates")) {
                    TextField("Last Interview", text: $newLastInterview)
                    TextField("Next Interview", text: $newNextInterview)
                }
                
                Section(header: Text("Technical Skills")) {
                    TextEditor(text: $newTechnicalSkills)
                        .frame(height: 150)
                }
                
                Button(action: {
                    addNewJob()
                }) {
                    Text("Add Job Application")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Add Job Application")
            .navigationBarItems(trailing: Button("Cancel") {
                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
            })
        }
    }
}

struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        JobApplicationTrackerView()
    }
}
