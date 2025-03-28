//
//  ArticleDetailViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import Foundation
import SwiftUI

protocol ArticleDetailViewModelCoordinatorDelegate: AnyObject {
    func goToArticleDetail(articleId: Int)
}

final class ArticleDetailViewModel: ObservableObject {
    weak var coordinatorDelegate: ArticleDetailViewModelCoordinatorDelegate?
    
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
                self.article = try await service.fetchArticle(id: articleId)
                self.viewState = .loaded
            }
            catch {
                print(error)
            }
        }
    }
    
    func goToArticleDetail(articleId: Int) {
        coordinatorDelegate?.goToArticleDetail(articleId: articleId)
    }
}
