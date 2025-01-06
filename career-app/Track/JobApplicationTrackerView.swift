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
                        .background(Color.red)
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
    
    @ViewBuilder
    private func buildDateText(lastInterview: String, nextInterview: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "arrowshape.turn.up.backward.2")
                    .resizable()
                    .foregroundColor(.thirdBlue.opacity(0.7))
                    .frame(width: 20, height: 20)
                Text(lastInterview)
                    .font(.system(size: 20))
                    .foregroundColor(.thirdBlue.opacity(0.7))
            }
            HStack {
                Image(systemName: "arrow.forward.circle.dotted")
                    .resizable()
                    .bold()
                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
                    .frame(width: 20, height: 20)
                Text(nextInterview)
                    .bold()
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header com informações da empresa e entrevistas
            HStack(alignment: .top) {
                Text(job.company)
                    .font(.system(size: 28))
                    .foregroundColor(.fivethBlue)
                
                Spacer()
                Button(action: {
//                    showAddForm.toggle()
                }) {
                    HStack{
                        Image(systemName: "pencil")
                            .resizable()
                            .clipped()
//                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.fourthBlue)
                            .frame(width: 24, height: 24)
//                        Image(systemName: "arrow.up.trash")
//                            .bold()
//                            .foregroundStyle(.white)
                        Text("Editar")
                            .font(.system(size: 24))
                            
                            .foregroundColor(.fourthBlue)
                            .cornerRadius(10)
                        
                    }
                    .shadow(radius: 0.5)
                    
                    
//                    .padding(.horizontal, 12)
//                    .background(Color.red)
//                    .cornerRadius(10)
                }
                
                
                if let lastInterview = job.lastInterview,
                   let nextInterview = job.nextInterview {
                    Spacer()
                    buildDateText(lastInterview: lastInterview, nextInterview: nextInterview)
                }
            }
            .padding(.bottom, 16)
            .padding(.trailing, 16)
           
            
            HStack(alignment: .top) {
                Text("Skills")
                    .font(.system(size: 24))
                    .foregroundColor(.fivethBlue)
                Spacer()
                
                Text(job.level)
                    .font(.system(size: 24))
                    .foregroundColor(.fivethBlue)
                
            }
            .padding(.trailing, 16)
            .padding(.bottom, 8)
            
            // Lista horizontal para as habilidades técnicas
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(job.technicalSkills, id: \.self) { skill in
                        Text(skill)
                            .bold()
                            .font(.system(size: 16))
                            .padding(.horizontal)
                            .frame(height: 32)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .foregroundColor(.white)
                            .background(Color.fourthBlue)
                            .cornerRadius(12)
                    }
                    // Ícone adicional ao final da lista
                    Image(systemName: "pencil")
                        .padding(16)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.backgroundLightGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.descriptionGray.opacity(0.5), lineWidth: 0.7)
        )
        .cornerRadius(10)
        
    }
}

//struct JobApplicationCard: View {
//    var job: JobApplication
//    
//    let gridColumns = [
//        GridItem(.flexible(), spacing: 4),
//        GridItem(.flexible(), spacing: 4),
//        GridItem(.flexible(), spacing: 4),
//        GridItem(.flexible(), spacing: 4)
//    ]
//    
//    @ViewBuilder
//    private func buildDateText(lastInterview: String, nextInterview: String) -> some View {
//        VStack {
//            HStack {
//                Image(systemName: "arrowshape.turn.up.backward.2")
//                    .foregroundColor(.descriptionGray)
//                Text(lastInterview)
//                    .font(.system(size: 20))
//                    .foregroundColor(.descriptionGray)
//            }
//            HStack {
//                Image(systemName: "arrow.forward.circle.dotted")
//                    .bold()
//                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
//                Text(nextInterview)
//
//                    .font(.system(size: 20))
//                    .foregroundColor(Color(red: 0, green: 94, blue: 66))
//            }
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(job.company)
//                    .font(.system(size: 20))
//                
//                Spacer()
//                Text(job.level)
//                    .font(.system(size: 20))
//                if let lastInterview = job.lastInterview,
//                    let nextInterview  = job.nextInterview
//                {
//                    Spacer()
//                    buildDateText(lastInterview: lastInterview, nextInterview: nextInterview)
//                    
//                }
//            }
//            
//            Text("Skills")
//                .font(.system(size: 24))
//                .foregroundColor(.secondary)
//                .padding(.bottom, 8)
//            
//            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 8) {
//                ForEach(job.technicalSkills, id: \.self) { skill in
//                    Text(skill)
//                        .bold()
//                        .font(.system(size: 9))
//                        .padding(8)
//                        .frame(width: 88, height: 40, alignment: .center)
//                        .multilineTextAlignment(.center)
//                        .lineLimit(2)
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(12)
//                    
//                    
//                    //                        .font(.caption)
//                    //                        .padding(8)
//                    //                        .background(Color.gray.opacity(0.2))
//                    //                        .cornerRadius(8)
//                }
//                Image(systemName: "pencil")
//                    .padding(16)
//                    .foregroundColor(Color.black)
//            }
//        }
//        .padding(.horizontal, 16)
//        .background(Color.white)
//        .cornerRadius(10)
//        Divider()
//    }
//}

struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        JobApplicationTrackerView()
    }
}
