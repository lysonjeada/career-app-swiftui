//
//  ArticleDetailViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import Foundation
import SwiftUI

final class ArticleDetailViewModel: ObservableObject {
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    private(set) var article: ArticleDetail?
    private var task: Task <Void, Never>?
    var articleId: Int
    
    private var service: ArticleService = ArticleService()
    
    init(articleId: Int) {
        self.articleId = articleId
    }
    
    @MainActor
    func fetchArticles() {
        viewState = .loading
        task = Task {
            do {
                // Mostra o loading por pelo menos 2 segundos
                try await Task.sleep(for: .seconds(2))
                
                // Verifica se a task não foi cancelada
                guard !Task.isCancelled else { return }
                
                let article = try await service.fetchArticle(id: articleId)
                
                // Verifica novamente antes de atualizar a UI
                guard !Task.isCancelled else { return }
                
                self.article = article
                self.viewState = .loaded
            } catch {
                guard !Task.isCancelled else { return }
                print(error)
//                self.viewState = .error(error)
            }
        }
    }

}
