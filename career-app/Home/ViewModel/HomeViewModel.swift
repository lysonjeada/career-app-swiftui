//
//  HomeViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/12/24.
//

import Foundation
import SwiftUI

protocol HomeViewModelCoordinatorDelegate: AnyObject {
    
}

final class HomeViewModel: ObservableObject {
    weak var coordinatorDelegate: HomeViewModelCoordinatorDelegate?
    
    enum State: Equatable {
        case loading
        case loaded
    }
    
    @Published private(set) var viewState: State = .loading
    
    private(set) var articles: [Article] = []
    private var task: Task <Void, Never>?
    
    private var service: HomeService = HomeService()
    
    init() {
        
    }
    
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
}
