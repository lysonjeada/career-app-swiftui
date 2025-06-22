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
    @State private var selectedJobTitle: String = "Cargo"
    @State private var selectedSeniority: String = "Senioridade"
    @State private var jobDescription: String = ""
    @State private var importing = false
    @State private var resumeFileURL: URL?
    @State private var resumeText: String = ""
    @State private var questions: [String] = []
    @State private var showQuestionsView = false
    @State private var currentIndex: Int = 0
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
                return Color(red: 0, green: 94, blue: 66)
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
        NavigationStack {
            ScrollView {
                VStack {
                    buildCarousel()
                        .frame(alignment: .top)
                    Divider()
                        .padding(.bottom, 16)
                    createNotesInterview()
                }
                .padding(.bottom, -keyboardObserver.keyboardHeight)
            }
            .sheet(isPresented: $showQuestionsView) {
                GenerateQuestionsAnswersSheet(generatedQuestions: viewModel.generatedQuestions, showQuestionsView: $showQuestionsView)
            }
            .toolbar {
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
    }
    
    @ViewBuilder
    func buildCarousel() -> some View {
        Carousel(index: $currentIndex,
                 currentIndex: $currentIndex,
                 buttonsEnabled: $isEnabled,
                 items: viewModel.steps) { step in
            CardHorizontal(isFillHeight: true)
                .content(
                    showTypeAndDescriptionJob(title: step.title, description: step.description, imageButton: step.imageButton, type: step.type))
            
        } onSwipe: { index in
            currentIndex = index
        }
        
        
    }
    
    @ViewBuilder
    func showTypeAndDescriptionJob(title: String, description: String?, imageButton: String, type: QuestionsGeneratorStep.Step.StepType) -> some View {
        VStack {
            buildHeader(title: title, description: description)
                .padding(.top, 12)
                .frame(alignment: .center)
            
            
            VStack {
                switch type {
                case .addCurriculum:
                    createButtonRow(addAction: {}, addSavedResumeAction: {})
                    //                    createButton(button: "rectangle.and.pencil.and.ellipsis", buttonAction: {
                    //                        generateInterviewQuestions()
                    //                        showQuestionsView = true
                    //                    })
                case .addInfoJob:
                    buildInfoJob()
                case .addDescriptionJob:
                    buildDescriptionJob()
                    //                    .padding(.bottom, 8)
                    
                }
            }
            
        }
        
        .frame(height: 296)
    }
    
    @ViewBuilder
    func buildHeader(title: String, description: String?) -> some View {
        VStack(alignment: .center) {
            Text("\(currentIndex + 1)")
                .bold()
                .font(.system(size: 24))
                .foregroundColor(.persianBlue)
                .padding(.bottom, 4)
            Text(title)
                .font(.system(size: 24))
                .foregroundColor(.thirdBlue)
                .padding(.bottom, 8)
            Text(description ?? "")
                .font(.system(size: 16))
                .lineLimit(nil)
                .lineSpacing(2)
            //                .padding(.horizontal, 16)
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.center)
            
        }
        
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    func buildDescriptionJob() -> some View {
        TextEditorView(text: $jobDescription, action: { actionDescriptionJob() })
    }
    
    private func actionDescriptionJob() {
        viewModel.generateQuestions()
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
    
    @ViewBuilder
    func createNotesInterview() -> some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("✏️ Faça anotações no pré, durante ou pós entrevista.")
                        .bold()
                        .font(.system(size: min(geometry.size.width * 0.05, 20))) // Responsive font size
                        .foregroundColor(.adaptiveBlack)
                    Text("Aproveite os momentos de pré entrevista para anotar sobre você e seus projetos, durante a entrevista anote pontos a melhorar/o que não soube responder e pós entrevista pensar os pontos a melhorar e o que deu certo!")
                        .font(.system(size: min(geometry.size.width * 0.03, 12)))
                        .foregroundColor(.descriptionGray)
                }
                .padding(.bottom, 8)
                
                HStack(spacing: 12) {
                    Button(action: {
                        // Try to open Notes app
                        let notesSchemes = ["mobilenotes://", "notes://"]
                        var opened = false
                        for scheme in notesSchemes {
                            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:]) { success in
                                    if !success { showNotesUnavailableAlert() }
                                }
                                opened = true
                                break
                            }
                        }
                        if !opened { showNotesUnavailableAlert() }
                    }) {
                        Text("Notas do Celular")
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.15) // 6% of container height
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    
                    Button(action: {
                        // Open your app's notes
                    }) {
                        Text("Notas do App")
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.15) // Same height as first button
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .frame(height: geometry.size.height * 0.16) // Slightly taller container for buttons
            }
            .padding()
            .background(Color.backgroundLightGray)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
            .padding(.horizontal)
        }
        .frame(height: 200) // Fixed height for the entire card
        .alert("Notas não disponível", isPresented: $showingNotesAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("O aplicativo de notas não pôde ser aberto. Você pode acessá-lo manualmente.")
        }
    }
    
    private func showNotesUnavailableAlert() {
        showingNotesAlert = true
    }
    
    @ViewBuilder
    func createTextHeader(stepText: String,
                          stepTitle: String,
                          description: String) -> some View {
        
        
        
    }
    
    @ViewBuilder
    func createButtonRow(
        addAction: @escaping () -> Void,
        addSavedResumeAction: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 24) { // Espaçamento entre os botões
            Button(action: addAction) {
                buttonContent(icon: "square.and.arrow.up", title: "Exportar", buttonType: .export)
            }
            
            Button(action: addSavedResumeAction) {
                buttonContent(icon: "doc.text", title: "Salvos", buttonType: .search)
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
    
    
    
    @ViewBuilder
    func showNextInterviews() -> some View {
        VStack {
            Text("Próximas Entrevistas")
                .font(.system(size: 24))
                .padding(.top, 16)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.titleSectionColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(jobApplications) { job in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(job.jobTitle ?? "Sem título")
                                .font(.headline)
                                .foregroundColor(Color.secondaryBlue)
                            
                            Text(job.nextInterview ?? "N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(job.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.backgroundLightGray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal)
                }
                //                .padding(.horizontal)
                
            }
            //            .padding(.bottom, 16)
            
            //            .padding(.horizontal)
        }
        
        .background(Color.backgroundLightGray)
        .cornerRadius(4)
        //        .shadow(radius: 2)
        //        .padding(.bottom, 80)
        //        .padding()
        //        Spacer()
        //        Divider()
    }
    
    func convertToText(url: URL) {
        if let pdfDocument = PDFDocument(url: url) {
            let pageCount = pdfDocument.pageCount
            var fullText = ""
            
            for pageIndex in 0..<pageCount {
                if let page = pdfDocument.page(at: pageIndex) {
                    if let pageText = page.string {
                        fullText += pageText
                    }
                }
            }
            resumeText = fullText // Store the extracted resume text
        }
    }
    
    
    
    //    func generateInterviewQuestions() {
    //        let messages: [[String: String]] = [
    //            ["role": "system", "content": "You are a helpful assistant that generates interview questions based on resume information, job title, seniority, and job description."],
    //            ["role": "user", "content": """
    //                    I have the following resume text:
    //                    \(resumeText)
    //
    //                    The job title is \(selectedJobTitle) and the seniority level is \(selectedSeniority).
    //
    //                    The job description is:
    //                    \(jobDescription)
    //
    //                    Please generate potential interview questions based on these details.
    //                    """
    //            ]
    //        ]
    //
    //        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    //        var request = URLRequest(url: url)
    //
    //        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"]  {
    //            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    //        }
    //
    //        request.httpMethod = "POST"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //
    //        let json: [String: Any] = [
    //            "model": "gpt-3.5-turbo",
    //            "messages": messages,
    //            "max_tokens": 150,
    //            "temperature": 0.7
    //        ]
    //
    //        let jsonData = try! JSONSerialization.data(withJSONObject: json)
    //        request.httpBody = jsonData
    //
    //        URLSession.shared.dataTask(with: request) { data, response, error in
    //            if let error = error {
    //                print("Erro: \(error.localizedDescription)")
    //                return
    //            }
    //
    //            if let data = data {
    //                let decoder = JSONDecoder()
    //                do {
    //                    let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
    //                    let content = openAIResponse.choices.first?.message.content ?? ""
    //
    //                    DispatchQueue.main.async {
    //                        self.questions = content.split(separator: "\n").map { String($0) }
    //                    }
    //                } catch {
    //                    print("Erro ao decodificar a resposta: \(error)")
    //                }
    //            }
    //        }.resume()
    //    }
}

struct InterviewGenerateQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewGenerateQuestionsView(viewModel: GenerateQuestionsViewModel())
    }
}
