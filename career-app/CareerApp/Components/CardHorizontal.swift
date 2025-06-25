//
//  CardHorizontal.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI

public struct CardHorizontal: View {
    private var contentView: (any View)?
    private var isFillHeight: Bool
    
    public init(isFillHeight: Bool = false) {
        self.isFillHeight = isFillHeight
    }
    
    private init(content: (any View)?,
                 isFillHeight: Bool) {
        self.contentView = content
        self.isFillHeight = isFillHeight
    }
    
    public var body: some View {
        Card() {
            ZStack(alignment: .top) {
                HStack(alignment: .top, spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .center, spacing: 8) {
                                if let contentView = contentView {
                                    AnyView(contentView)
                                        .accessibilityRemoveTraits(.isStaticText)
                                }
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.leading, 8)
            }
            
        }
        .fixedSize(horizontal: false, vertical: !isFillHeight)
        
    }
    
    public func content<Content: View>(_ view: Content?) -> CardHorizontal {
        return CardHorizontal(content: view, isFillHeight: isFillHeight)
    }
    
}

struct CardHorizontal_Previews: PreviewProvider {
    @State private static var currentIndex: Int = 0
    @State private static var isEnabled = true
    private static var viewModel: GenerateQuestionsViewModel {
        GenerateQuestionsViewModel()
    }
    @State private static var selectedJobTitle: String = "Cargo"
    @State private static var selectedSeniority: String = "Senioridade"
    @State private static var jobDescription: String = ""
    @State private static var resumeFileURL: URL?
    @State private static var resumeText: String = ""
    @State private static var questions: [String] = []
    @State private static var showQuestionsView = false
    @State var isEnabled = true
    @StateObject var viewModel: GenerateQuestionsViewModel
    
    static var jobTitles = [
        "Full Stack Developer",
        "Backend Developer",
        "Frontend Developer",
        "Gaming Engineer",
        "Blockchain Engineer",
        "iOS Developer",
        "Android Developer",
        "Cross Platform (Mobile)"
    ]
    
    static var seniorityLevels = [
        "Intern",
        "Junior",
        "Mid-level",
        "Senior",
        "Lead",
        "Manager"
    ]
    
    static var previews: some View {
        CardHorizontal()
            .content(showTypeAndDescriptionJob(title: "Faça o download do seu\ncurrículo", description: "Certifique-se de que seu currículo está atualizado e co suas habilidades bem expostas, isso ajuda o gerador de perguntas a ser mais assertivo.", imageButton: "doc.fill", type: .addCurriculum))
    }
    
    @ViewBuilder
    static func showTypeAndDescriptionJob(title: String, description: String?, imageButton: String, type: QuestionsGeneratorStep.Step.StepType) -> some View {
        VStack {
            VStack(alignment: .leading) {
                createTextHeader(stepText: "\(currentIndex + 1)",
                                 stepTitle: title)
                
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                if type == .addInfoJob {
                    buildInfoJob()
                } else if type == .addDescriptionJob {
                    buildDescriptionJob()
                }
            }
            VStack(alignment: .center) {
                createButton(button: "rectangle.and.pencil.and.ellipsis", buttonAction: {
                    
                })
            }
        }
        
//        .frame(maxHeight: 300)
    }
    
    @ViewBuilder
    static func createTextHeader(stepText: String,
                          stepTitle: String) -> some View {
        VStack(alignment: .leading) {
            Text(stepText)
                .font(.system(size: 24))
                .foregroundColor(.persianBlue)
                .padding(.top, 16)
                .padding(.bottom, 8)
            Text(stepTitle)
                .font(.system(size: 20))
                .foregroundColor(.backgroundGray)
        }
    }
    
    @ViewBuilder
    static func createButton(button: String,
                      buttonAction: @escaping () -> Void) -> some View {
        Button(action: buttonAction) {
            HStack {
                Image(systemName: button)
                    .frame(width: 24, height: 24)
                Text("+")
                    .bold()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(minWidth: 0)
            .background(Color.persianBlue)
            .foregroundColor(.white)
            .cornerRadius(48)
            .shadow(radius: 1)
        }
    }
    
    @ViewBuilder
    static func buildDescriptionJob() -> some View {
        TextEditor(text: $jobDescription)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.backgroundLightGray)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.persianBlue, lineWidth: 1)
            )
    }
    
    @ViewBuilder
    static func buildInfoJob() -> some View {
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
    }
}
