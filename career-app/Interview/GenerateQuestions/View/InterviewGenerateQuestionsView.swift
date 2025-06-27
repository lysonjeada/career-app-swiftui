//
//  InterviewGenerateQuestionsView.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 25/08/24.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct InterviewGenerateQuestionsView: View {
    
    @FocusState private var keyboardFocused: Bool
    @State private var selectedJobTitle: String = "Cargo"
    @State private var selectedSeniority: String = "Senioridade"
    @State private var jobDescription: String = ""
    @State private var importing = false
    @State private var resumeFileURL: URL?
    @State private var resumeText: String = ""
    @State private var questions: [String] = []
    @State private var showQuestionsView = false
    @State private var currentIndex: Int = 0
    @State private var didExportResume: Bool = false
    @State var isEnabled = true
    @StateObject var viewModel: GenerateQuestionsViewModel
    @State private var maxHeight: CGFloat = 0
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var showingNotesAlert = false
    
    let jobTitles = [
        "Full Stack Developer",
        "Backend Developer",
        "Frontend Developer",
        "Gaming Engineer",
        "Blockchain Engineer",
        "iOS Developer",
        "Android Developer",
        "Cross Platform (Mobile)"
    ]
    
    let seniorityLevels = [
        "Intern",
        "Junior",
        "Mid-level",
        "Senior",
        "Lead",
        "Manager"
    ]
    
    enum ButtonType {
        case export
        case search
        
        var colorFill: Color {
            switch self {
            case .export:
                // rgb(0, 115, 19)
                return Color.persianBlue
            case .search:
                return Color.persianBlue
            }
        }
    }
    
    @State private var jobApplications = [
        JobApplication(company: "PagBank", level: "Pleno", role: "iOS Developer", nextInterview: "18/09/2024", jobTitle: "iOS Developer"),
        JobApplication(company: "Nubank", level: "Sênior", role: "iOS Developer", nextInterview: "25/09/2024", jobTitle: "Backend Engineer"),
        JobApplication(company: "Itaú", level: "Júnior", role: "iOS Developer", nextInterview: "02/10/2024", jobTitle: "Data Analyst")
    ]
    
    private var profileButton: some View {
        Button(action: {
            // Ação do botão de perfil
        }) {
            Image(systemName: "person.circle")
                .resizable()
                .clipShape(Circle())
                .frame(width: 35, height: 35)
                .foregroundColor(Color.persianBlue)
        }
    }
    
    var body: some View {
        VStack {
            buildCarousel()
                .frame(alignment: .top)
            Divider()
                .padding(.bottom, 16)
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // the Spacer will push the Done button to the far right of the keyboard as pictured.
                Spacer()
                
                Button(action: {
                    keyboardFocused = false
                }, label: {
                    Text("Done")
                })
                
            }
        }
        .ignoresSafeArea(.keyboard)
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
//        .padding(.bottom, -keyboardObserver.keyboardHeight)
        .sheet(isPresented: $showQuestionsView) {
            GenerateQuestionsAnswersSheet(showQuestionsView: $showQuestionsView, viewModel: viewModel, selectedJobTitle: $selectedJobTitle, selectedSeniority: $selectedSeniority, jobDescription: $jobDescription, resumeFileURL: $resumeFileURL)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                // the Spacer will push the Done button to the far right of the keyboard as pictured.
                Spacer()
                
                if keyboardFocused {
                    Button(action: {
                        keyboardFocused = false
                    }, label: {
                        Text("Done")
                    })
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Text("Entrevistas")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.persianBlue)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                profileButton
            }
        }
        .toolbarBackground(Color.backgroundLightGray, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        //            .padding(.bottom, keyboardObserver.keyboardHeight)
        //            .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
    }
    
    @ViewBuilder
    func buildCarousel() -> some View {
        NativeCarousel(
            currentIndex: $currentIndex,
            items: viewModel.steps
        ) { step in
            CardHorizontal(isFillHeight: true)
                .content(
                    showTypeAndDescriptionJob(
                        title: step.title,
                        description: step.description,
                        imageButton: step.imageButton,
                        type: step.type
                    )
                )
        } onSwipe: { index in
            currentIndex = index
        }
    }
    
    @ViewBuilder
    func showTypeAndDescriptionJob(title: String, description: String?, imageButton: String, type: QuestionsGeneratorStep.Step.StepType) -> some View {
        VStack(spacing: 16) {
            buildHeader(title: title, description: description)
            
            switch type {
            case .addCurriculum:
                createButtonRow(addAction: {}, addSavedResumeAction: {})
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .center)
                
            case .addInfoJob:
                buildInfoJob()
            case .addDescriptionJob:
                buildDescriptionJob()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    
    @ViewBuilder
    func buildHeader(title: String, description: String?) -> some View {
        VStack(spacing: 8) {
            Text("\(currentIndex + 1)")
                .bold()
                .font(.system(size: 24))
                .foregroundColor(.persianBlue)
            
            Text(title)
                .font(.system(size: 22))
                .foregroundColor(.thirdBlue)
            
            Text(description ?? "")
                .font(.system(size: 16))
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
    
    
    @ViewBuilder
    func buildDescriptionJob() -> some View {
        TextEditorView(text: $jobDescription, action: actionDescriptionJob)
            .focused($keyboardFocused)
    }
    
    private func actionDescriptionJob() {
        guard let resumeURL = resumeFileURL else { return }
        showQuestionsView = true
    }
    
    @ViewBuilder
    func buildInfoJob() -> some View {
        VStack {
            VStack {
                Menu {
                    ForEach(jobTitles, id: \.self) { title in
                        Button(action: {
                            selectedJobTitle = title
                        }) {
                            Text(title)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedJobTitle)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.persianBlueWithoutOpacity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlueWithoutOpacity, lineWidth: 1))
                }
                
                Menu {
                    ForEach(seniorityLevels, id: \.self) { level in
                        Button(action: {
                            selectedSeniority = level
                        }) {
                            Text(level)
                                .foregroundColor(.persianBlueWithoutOpacity)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSeniority)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.persianBlueWithoutOpacity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlueWithoutOpacity, lineWidth: 1))
                }
            }
            .frame(height: 100)
            .padding(.horizontal)
        }
        .padding(.horizontal)
        
    }
    
    
    
    private func showNotesUnavailableAlert() {
        showingNotesAlert = true
    }
    
    @ViewBuilder
    func createButtonRow(
        addAction: @escaping () -> Void,
        addSavedResumeAction: @escaping () -> Void
    ) -> some View {
        Button(action: {
            importing = true
        }) {
            buttonContent(
                icon: didExportResume ? "checkmark.circle.fill" : "square.and.arrow.up",
                title: didExportResume ? "Exportado!" : "Exportar",
                buttonType: .export
            )
        }
        .fileImporter(
            isPresented: $importing,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let selected = urls.first {
                    resumeFileURL = selected
                    didExportResume = true
                    
                    // (Opcional) Voltar para o estado original depois de 2 segundos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        didExportResume = false
                    }
                }
            case .failure(let error):
                print("Erro ao importar arquivo:", error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private func buttonContent(icon: String, title: String, buttonType: ButtonType) -> some View {
        VStack {
            ZStack {
                Circle()
                    .fill(buttonType.colorFill)
                    .frame(width: 60, height: 60)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(alignment: .center)
            
            Text(title)
                .bold()
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(buttonType.colorFill)
                .padding(.vertical)
        }
        
    }
    
    
    @ViewBuilder
    func createButton(button: String, buttonAction: @escaping () -> Void) -> some View {
        Button(action: buttonAction) {
            ZStack {
                Circle()
                    .fill(Color.persianBlue)
                    .frame(width: 80, height: 80)
                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 4) // Sombra leve
                
                VStack(spacing: 4) {
                    Image(systemName: button)
                        .font(.system(size: 20, weight: .bold)) // Ícone maior
                        .foregroundColor(.white)
                    Text("+")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct InterviewGenerateQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewGenerateQuestionsView(viewModel: GenerateQuestionsViewModel())
    }
}
