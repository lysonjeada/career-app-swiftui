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
    
    @State private var jobApplications = [
        JobApplication(company: "PagBank", level: "Pleno", nextInterview: "18/09/2024", jobTitle: "iOS Developer"),
        JobApplication(company: "Nubank", level: "Sênior", nextInterview: "25/09/2024", jobTitle: "Backend Engineer"),
        JobApplication(company: "Itaú", level: "Júnior", nextInterview: "02/10/2024", jobTitle: "Data Analyst")
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
            VStack {
                buildCarousel()
                    .frame(alignment: .top)
                
                Divider()
                Spacer()
                
                
                showNextInterviews()
                
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
        VStack {
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
        .padding(.bottom, keyboardObserver.keyboardHeight)
        .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
        
        
    }
    
    @ViewBuilder
    func showTypeAndDescriptionJob(title: String, description: String?, imageButton: String, type: QuestionsGeneratorStep.Step.StepType) -> some View {
        VStack {
            buildHeader(title: title, description: description)
                .padding(.top, 12)
            Spacer()
            
            VStack {
                switch type {
                case .addCurriculum:
                    createButton(button: "rectangle.and.pencil.and.ellipsis", buttonAction: {
                        generateInterviewQuestions()
                        showQuestionsView = true
                    })
                case .addInfoJob:
                    buildInfoJob()
                case .addDescriptionJob:
                    buildDescriptionJob()
                }
            }
            .padding(.bottom, 24)
        }
        .frame(height: 260)
        
    }
    
    @ViewBuilder
    func buildHeader(title: String, description: String?) -> some View {
        VStack {
            Text("\(currentIndex + 1)")
                .font(.system(size: 24))
                .foregroundColor(.persianBlue)
                .padding(.bottom, 8)
            Text(title)
                .font(.system(size: 20))
                .foregroundColor(.backgroundGray)
                .padding(.bottom, 8)
            Text(description ?? "")
                .font(.subheadline)
                .lineLimit(nil)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
        }
        .frame(alignment: .top)
        
    }
    
    @ViewBuilder
    func buildDescriptionJob() -> some View {
        TextEditorView(text: $jobDescription)
            .frame(height: 80)
    }
    
    @ViewBuilder
    func buildInfoJob() -> some View {
        VStack {
            HStack {
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
                    .foregroundColor(.persianBlue)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                }
                
                Menu {
                    ForEach(seniorityLevels, id: \.self) { level in
                        Button(action: {
                            selectedSeniority = level
                        }) {
                            Text(level)
                                .foregroundColor(.persianBlue)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSeniority)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.persianBlue)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                }
            }
            .frame(height: 80)
        }
        .padding(.horizontal)
        
    }
    
    //    @ViewBuilder
    //    func createStepHeader(stepText: String,
    //                          stepTitle: String,
    //                          button: String,
    //                          description: String,
    //                          buttonAction: @escaping () -> Void) -> some View {
    //        VStack(alignment: .center) {
    //            createTextHeader(stepText: stepText, stepTitle: stepTitle, description: description)
    //                .padding(.bottom, 16)
    //
    //
    //            createButton(button: button, buttonAction: buttonAction)
    //        }
    //    }
    
    @ViewBuilder
    func createTextHeader(stepText: String,
                          stepTitle: String,
                          description: String) -> some View {
        
        
        
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
    
    func generateInterviewQuestions() {
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant that generates interview questions based on resume information, job title, seniority, and job description."],
            ["role": "user", "content": """
                    I have the following resume text:
                    \(resumeText)
                    
                    The job title is \(selectedJobTitle) and the seniority level is \(selectedSeniority).
                    
                    The job description is:
                    \(jobDescription)
                    
                    Please generate potential interview questions based on these details.
                    """
            ]
        ]
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        
        if let apiKey = ProcessInfo.processInfo.environment["API_KEY"]  {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 150,
            "temperature": 0.7
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
                    let content = openAIResponse.choices.first?.message.content ?? ""
                    
                    DispatchQueue.main.async {
                        self.questions = content.split(separator: "\n").map { String($0) }
                    }
                } catch {
                    print("Erro ao decodificar a resposta: \(error)")
                }
            }
        }.resume()
    }
}

struct TextEditorView: View {
    @Binding var text: String
    @State private var isExpanded: Bool = false
    @StateObject private var keyboardObserver = KeyboardObserver()
    @FocusState private var isFocused: Bool
    
    var body: some View {
            ZStack {
                // Área clicável para "fora do TextEditor"
                Color.clear
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            if isExpanded {
                                isExpanded = false
                                isFocused = false // Remove o foco
                            }
                        }
                    }
                
                VStack {
                    TextEditor(text: $text)
                        .frame(height: isExpanded ? 80 : 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.backgroundLightGray)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.persianBlue, lineWidth: 1)
                        )
                        .focused($isFocused)
                        .onChange(of: isFocused) { newValue in
                            withAnimation(.easeInOut) {
                                isExpanded = newValue
                            }
                        }
                    if isExpanded {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isExpanded = false
                                isFocused = false
                            }
                        }) {
                            Text("Concluir")
                                .font(.footnote)
                                .padding(.top, 8)
                                .foregroundColor(.persianBlue)
                        }
                    }
                        
                }
                .padding(.horizontal, isExpanded ? 16 : 72)
//                .padding(.top, keyboardObserver.keyboardHeight)
//                .padding(.bottom, keyboardObserver.keyboardHeight > 0 ? keyboardObserver.keyboardHeight : -120)
                
            }
            
        //        .frame(height: 120)
        //        .frame(maxHeight: 60)
        
        .ignoresSafeArea()
        //        .padding(.bottom, keyboardObserver.keyboardHeight)
        //        .animation(.easeInOut, value: keyboardObserver.keyboardHeight)
    }
}

struct InterviewGenerateQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewGenerateQuestionsView(viewModel: GenerateQuestionsViewModel())
    }
}
