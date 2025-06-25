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
    @State private var jobApplications = []
    @StateObject private var viewModel = AddJobApplicationViewModel()
    @State private var newCompany = ""
    @State private var newLevel = ""
    @State private var newRole = ""
    @State private var newLastInterview = ""
    @State private var newNextInterview = ""
    @State private var newTechnicalSkills = ""
    @State private var showAddForm = false
    @State private var isAnimating = false
    @State private var isEditingMode = false
    @StateObject var coordinator: Coordinator
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack {
                        if viewModel.jobApplications.isEmpty {
                            EmptyStateView()
                        } else {
                            ApplicationsListView(
                                applications: viewModel.jobApplications,
                                isEditingMode: $isEditingMode,
                                onEdit: editJob
                            )
                        }
                    }
                    .padding(.bottom, 80) // Espaço para os botões flutuantes
                }
                
                FloatingActionButtons(
                    isEditingMode: $isEditingMode,
                    showAddForm: $showAddForm,
                    coordinator: coordinator
                )
            }
            .navigationTitle("Candidaturas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showAddForm) {
                AddJobApplicationForm(
                                        newCompany: $newCompany,
                                        newLevel: $newLevel,
                                        newLastInterview: $newLastInterview,
                                        newNextInterview: $newNextInterview,
                                        newTechnicalSkills: $newTechnicalSkills
                                    )
            }
            .onAppear { viewModel.fetchJobApplications() }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Candidaturas")
                .bold()
                .font(.system(size: 28))
                .foregroundColor(.persianBlue)
        }
    }
    
    // Função para adicionar um novo trabalho
    func addNewJob() {
//        let technicalSkillsArray = newTechnicalSkills
//            .split(separator: ",")
//            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//        
//        let newJob = JobApplication(
//            company: newCompany,
//            level: newLevel,
//            role: newRole,
//            lastInterview: newLastInterview.isEmpty ? nil : newLastInterview,
//            nextInterview: newNextInterview.isEmpty ? nil : newNextInterview,
//            technicalSkills: technicalSkillsArray,
//            jobTitle: nil
//        )
//        jobApplications.append(newJob)
//        clearForm()
        
    }
    
    func editJob() {
        coordinator.push(page: .editJob)
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

// MARK: - Subviews

private struct EmptyStateView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Nada foi encontrado :(")
                .bold()
                .font(.title)
                .foregroundColor(.persianBlue)
                .padding(.top, 49)
            
            Text("Parece que você ainda não adicionou\nnenhuma candidatura.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.bottom, 160)
            
            AnimatedPrompt()
        }
        .padding()
    }
}

private struct AnimatedPrompt: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Text("Clique para adicionar")
                .bold()
                .foregroundColor(.persianBlue)
                .shadow(radius: 0.3)
                .offset(y: isAnimating ? -10 : 10)
            
            Image(systemName: "arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .foregroundColor(.persianBlue)
                .offset(y: isAnimating ? -10 : 10)
        }
        .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
        .padding(.bottom, 100)
    }
}

private struct ApplicationsListView: View {
    let applications: [JobApplication]
    @Binding var isEditingMode: Bool
    let onEdit: () -> Void
    
    var body: some View {
        ForEach(applications) { job in
            JobApplicationCard(
                job: job,
                isEditingMode: isEditingMode,
                editAction: { onEdit() },
                deleteAction: { /* Implementar deleção */ }
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

private struct FloatingActionButtons: View {
    @Binding var isEditingMode: Bool
    @Binding var showAddForm: Bool
    var coordinator: Coordinator
    
    var body: some View {
        HStack(spacing: 16) {
            ActionButton(
                title: isEditingMode ? "Concluir" : "Apagar",
                icon: isEditingMode ? "checkmark" : "trash",
                color: isEditingMode ? .green : .red,
                action: { isEditingMode.toggle() }
            )
            
            ActionButton(
                title: "Adicionar",
                icon: "plus",
                color: Color(red: 0, green: 0.37, blue: 0.26),
                action: { coordinator.push(page: .addJob) }
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}


struct JobApplicationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
