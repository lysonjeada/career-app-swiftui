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
}
