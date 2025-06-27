//
//  HomeViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation
import SwiftUI

protocol HomeViewModelCoordinatorDelegate: AnyObject {
    func goToArticleDetail(articleId: Int)
}

final class HomeViewModel: ObservableObject {
    @Published var selectedTag: String = "Todos"
    weak var coordinatorDelegate: HomeViewModelCoordinatorDelegate?
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    private(set) var articles: [Article] = []
    private var task: Task <Void, Never>?
    
    private var service: HomeService = HomeService()
    
    @MainActor
    func fetchArticles(tag: String? = nil) {
        viewState = .loading
        task = Task {
            do {
                self.articles = try await service.fetchArticles(tag: tag)
                self.viewState = .loaded
            } catch {
                print("Erro ao buscar artigos:", error)
            }
        }
    }
    
    func goToArticleDetail(articleId: Int) {
        coordinatorDelegate?.goToArticleDetail(articleId: articleId)
    }
}
