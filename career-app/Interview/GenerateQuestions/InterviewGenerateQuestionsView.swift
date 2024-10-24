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
    @State private var selectedJobTitle: String = "Select Job Title"
    @State private var selectedSeniority: String = "Select Seniority"
    @State private var jobDescription: String = ""
    @State private var importing = false
    @State private var resumeFileURL: URL?
    @State private var resumeText: String = ""
    
    @State private var questions: [String] = []
    @State private var showQuestionsView = false
    
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    VStack {
                        Text("1")
                            .font(.largeTitle)
                            .foregroundColor(.persianBlue)
                        Spacer()
                        Text("Upload Your Resume")
                            .font(.headline)
                            .foregroundColor(.backgroundGray)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                    .cornerRadius(10)
                    
                    Button(action: {
                        importing = true
                    }) {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Upload Resume")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.vertical)
                    .fileImporter(
                        isPresented: $importing,
                        allowedContentTypes: [.pdf, .plainText],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let selectedFile):
                            resumeFileURL = selectedFile.first
                            if let fileURL = resumeFileURL {
                                convertToText(url: fileURL)
                            }
                            
                        case .failure(let error):
                            print("File selection failed: \(error.localizedDescription)")
                        }
                    }
                    
                    VStack {
                        Text("2")
                            .font(.largeTitle)
                            .foregroundColor(.persianBlue)
                        Spacer()
                        Text("Add Job Description")
                            .font(.headline)
                            .foregroundColor(.backgroundGray)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding()
                    .cornerRadius(10)
                    
                    Text("Add a job description by Generate a sample of job description or Copy-paste a job description")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
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
                    
                    TextEditor(text: $jobDescription)
                        .frame(height: 100)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.persianBlue, lineWidth: 1))
                    
                    //                Spacer()
                    
                    Button(action: {
                        generateInterviewQuestions()
                        showQuestionsView = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            Text("Perguntas")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.persianBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .navigationDestination(isPresented: $showQuestionsView) {
                        InterviewQuestionsView(questions: questions)
                    }
                }
            }
            
            .padding()
            .background(.white) // Cor de fundo para toda a view
        }
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

struct InterviewGenerateQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewGenerateQuestionsView()
    }
}
