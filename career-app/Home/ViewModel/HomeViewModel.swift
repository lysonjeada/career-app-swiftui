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
    weak var coordinatorDelegate: HomeViewModelCoordinatorDelegate? {
        didSet {
            print("coordinatorDelegate foi atribuído: \(coordinatorDelegate != nil)")
        }
    }
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    private(set) var articles: [Article] = []
    private var task: Task <Void, Never>?
    
    private var service: HomeService = HomeService()
    
    @MainActor
    func fetchArticles() {
        viewState = .loading
        task = Task {
            do {
                self.articles = try await service.fetchArticles()
                self.viewState = .loaded
            }
            catch {
                
            }
        }
    }
    
    func goToArticleDetail(articleId: Int) {
        coordinatorDelegate?.goToArticleDetail(articleId: articleId)
    }
}
