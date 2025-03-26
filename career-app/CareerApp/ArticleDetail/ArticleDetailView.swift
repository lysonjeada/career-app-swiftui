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
        NavigationStack {
            switch viewModel.viewState {
            case .loading:
                VStack {
                    
                }
            case .loaded:
                VStack {
                    Text(viewModel.article?.title ?? "Não encontrado")
                    Text(viewModel.article?.description ?? "Não encontrado")
                        .lineLimit(nil)
                    VStack {
                        ScrollView {
                            Text(.init(viewModel.article?.bodyMarkdown ?? ""))
                        }
                    }
                    
                }
                //                VStack {
                //                    ScrollView {
                //                        if let bodyHtml = viewModel.article?.bodyHtml,
                //                           let attributedString = bodyHtml.htmlToAttributedString {
                //                            Text(attributedString)
                //                                .font(.body)
                //                                .padding(.vertical, 8)
                //                        } else {
                //                            Text("Erro ao carregar o conteúdo.")
                //                                .foregroundColor(.red)
                //                        }
                //                    }
                //                }
                
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
