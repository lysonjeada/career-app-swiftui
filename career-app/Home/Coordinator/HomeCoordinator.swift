//
//  HomeCoordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import SwiftUI

final class HomeCoordinator: Coordinator {
    
    weak var delegate: CoordinatorDelegate?
    var childCoordinator: Coordinator?
    var viewController: UIViewController!
    var navigationController: UINavigationController?
    
    init() {
        let viewModel = HomeViewModel()
        let view = HomeView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)
        self.viewController = viewController
    }
    
    private func presentArticleDetail(with articleId: Int) {
        // TODO: Criar view model, view, view controller e setar modal presentation style para dar o present pela nv
    }
    
}

extension HomeCoordinator: HomeViewModelCoordinatorDelegate {
    func goToArticleDetail(articleId: Int) {
        presentArticleDetail(with: articleId)
    }
    
    
}
