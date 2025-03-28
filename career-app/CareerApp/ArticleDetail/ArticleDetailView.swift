//
//  ArticleDetailView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import SwiftUI

struct ArticleDetailView: View {
    @State private var showFullArticleList = false
    @StateObject var viewModel: ArticleDetailViewModel
    private let articleLimit = 10
    
    @State private var jobApplications = [
        JobApplication(company: "PagBank", level: "Pleno", nextInterview: "18/09/2024", jobTitle: "iOS Developer"),
        JobApplication(company: "Nubank", level: "Sênior", nextInterview: "25/09/2024", jobTitle: "Backend Engineer"),
        JobApplication(company: "Itaú", level: "Júnior", nextInterview: "02/10/2024", jobTitle: "Data Analyst")
    ]
    
    @State private var searchText = ""
    
    private var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.circle")
                .resizable()
                .clipShape(Circle())
                .frame(width: 35, height: 35)
                .foregroundColor(Color.persianBlue)
        }
    }
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                VStack {
                    
                }
            case .loaded:
                VStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.article?.title ?? "Não encontrado")
                            .bold()
                            .font(.system(size: 24))
                            .lineLimit(nil)
                            .padding(.bottom, 4)
                            .padding(.top, 16)
                        Text(viewModel.article?.description ?? "Não encontrado")
                            .font(.system(size: 20))
                            .lineLimit(nil)
                            .padding(.bottom, 8)
                        TagCloudView(tags: viewModel.article?.tags ?? [])
                            .padding(.bottom, 9)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.article?.user?.name ?? "Não encontrado")
                                    .font(.system(size: 16))
                                Spacer()
                                Text(viewModel.article?.user?.username ?? "Não encontrado")
                                    .font(.system(size: 16))
                            }
                            
                        }
                        VStack {
                            ScrollView {
                                if let body = viewModel.article?.bodyHtml {
                                    Text(body)
                                }
    //                            Text(viewModel.article?.bodyMarkdown ?? "")
                            }
                        }
                        
                    }
                    .padding(.horizontal, 16)
                }
                
                
            }
        }
        .onAppear {
            viewModel.fetchArticles()
        }
        
            
    }
    
    func decodeHTMLEntities(_ string: String) -> String {
        return string.replacingOccurrences(of: "\\u003C", with: "<")
            .replacingOccurrences(of: "\\u003E", with: ">")
    }
    
    /// Converte HTML para texto simples
    func htmlToPlainText(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return "" }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return ""
    }
}

#Preview {
    ArticleDetailView(viewModel: ArticleDetailViewModel(articleId: 2315711))
}

// Extensão para converter HTML em AttributedString
extension String {
    var htmlToAttributedString: AttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            let nsAttributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return try AttributedString(nsAttributedString, including: \.swiftUI)
        } catch {
            print("Erro ao converter HTML: \(error)")
            return nil
        }
    }
}
