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
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fundo Persian Blue com opacidade
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                // Conteúdo principal
                switch viewModel.viewState {
                case .loading:
                    LoadingView()
                case .loaded:
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Título
                            Text(viewModel.article?.title ?? "Artigo não encontrado")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.persianBlue)
                                .lineLimit(nil)
                                .padding(.top, 20)
                            
                            TagCloudView(tags: viewModel.article?.tags ?? [])
                                .padding(.top, 4)
                            
                            // Descrição
                            Text(viewModel.article?.description ?? "Descrição não disponível")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.backgroundGray)
                                .lineLimit(nil)
                            
                            // Tags
                            
                            
                            // Autor
                            HStack {
                                Text(viewModel.article?.user?.name ?? "Autor desconhecido")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(.persianBlue.opacity(0.9))
                                    .italic()
                                
                                Spacer()
                                
                                Text(viewModel.article?.user?.username ?? "@user")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(.persianBlue.opacity(0.9))
                                    .italic()
                            }
                            
                            // Botão "IR ATÉ O ARTIGO"
                            ArticleDetailButton {
                                if let stringURL = viewModel.article?.url,
                                   let url = URL(string: stringURL) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .padding(.vertical, 16)
                            
                            // Corpo do artigo
                            if let body = viewModel.article?.bodyHtml {
                                Text(htmlToPlainText(body))
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineSpacing(6)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .onAppear {
                viewModel.fetchArticles()
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.article?.title ?? "")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }
    
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
