//
//  AddJobApplicationForm.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/01/25.
//

import SwiftUI

struct AddJobApplicationForm: View {
    @State private var company = ""
    @State private var level = ""
    @State private var jobTitle = ""
    @State private var lastInterview = ""
    @State private var nextInterview = ""
    @State private var location = ""
    @State private var notes = ""

    @State private var selectedSeniority: String = ""
    @State private var selectedRole: String = ""
    @State private var skills: [String] = []
    @State private var showSkillSheet: Bool = false
    @State private var isSelectionModeActive: Bool = false

    @StateObject var viewModel: JobApplicationTrackerListViewModel
    @StateObject var coordinator: Coordinator

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case company, level, jobTitle, location, notes
    }

    let seniorityLevels = ["Intern", "Junior", "Mid-level", "Senior", "Lead", "Manager"]
    let roleList = ["iOS Developer", "Backend Developer", "Frontend Developer"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Nova Candidatura")
                    .font(.title)
                    .bold()

                // Empresa
                textField("Nome da empresa", text: $company, field: .company)

                // Cargo e Senioridade
                menuWithFallback(title: "Cargo", selected: $selectedRole, options: roleList, fallbackText: $jobTitle, fallbackField: .jobTitle)
                menuWithFallback(title: "Senioridade", selected: $selectedSeniority, options: seniorityLevels, fallbackText: $level, fallbackField: .level)

                // Localização e Notas (opcional)
                textField("Localização", text: $location, field: .location)
                textField("Notas", text: $notes, field: .notes)

                // Datas
                DateInputField(dateString: $nextInterview, placeholder: "Próxima entrevista")
                DateInputField(dateString: $lastInterview, placeholder: "Última entrevista")

                Divider()

                // Skills
                skillsSection

                // Enviar
                Button(action: submitForm) {
                    Text("Adicionar Candidatura")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationConfig(title: "Adicionar Candidatura", backAction: coordinator.pop)
    }

    // MARK: - Components

    @ViewBuilder
    func textField(_ placeholder: String, text: Binding<String>, field: Field) -> some View {
        TextField(placeholder, text: text)
            .focused($focusedField, equals: field)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.persianBlue, lineWidth: 1)
            )
    }

    @ViewBuilder
    func menuWithFallback(
        title: String,
        selected: Binding<String>,
        options: [String],
        fallbackText: Binding<String>,
        fallbackField: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selected.wrappedValue = option
                    }
                }
            } label: {
                HStack {
                    Text(selected.wrappedValue.isEmpty ? "Selecionar..." : selected.wrappedValue)
                        .foregroundColor(.persianBlue)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.persianBlue, lineWidth: 1)
                )
            }

            if selected.wrappedValue.isEmpty {
                textField("Outro (digite aqui)", text: fallbackText, field: fallbackField)
            }
        }
    }

    private var skillsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Skills")
                    .font(.headline)

                Spacer()

                Button(action: { showSkillSheet.toggle() }) {
                    Image(systemName: "plus")
                        .padding(8)
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                Button(action: { isSelectionModeActive.toggle() }) {
                    Image(systemName: "minus")
                        .padding(8)
                        .background(Color.white)
                        .foregroundColor(.persianBlue)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.persianBlue, lineWidth: 2)
                        )
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(isSelectionModeActive ? Color.red : Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .onTapGesture {
                            if isSelectionModeActive {
                                skills.removeAll(where: { $0 == skill })
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showSkillSheet) {
            SkillSelectionView(selectedSkills: $skills)
        }
    }

    // MARK: - Actions

    private func submitForm() {
        viewModel.addInterview(
            companyName: company,
            jobTitle: selectedRole.isEmpty ? jobTitle : selectedRole,
            jobSeniority: selectedSeniority.isEmpty ? level : selectedSeniority,
            lastInterview: lastInterview,
            nextInterview: nextInterview,
            location: location,
            skills: skills
        )
        coordinator.pop()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
            AddJobApplicationForm(viewModel: JobApplicationTrackerListViewModel(), coordinator: Coordinator())
        }
        .previewDevice("iPhone 14")
        .previewDisplayName("Add Job Application Form")
    }
}


