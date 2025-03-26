//
//  HomeCoordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import SwiftUI

import Foundation
import SwiftUI

enum AuthenticationPage {
    case login, forgotPassword
}

final class HomeCoordinator: Hashable {
    
    @Binding var navigationPath: NavigationPath

    private var id: UUID
    private var output: Output?
    private var page: AuthenticationPage

    struct Output {
        var goToMainScreen: () -> Void
    }

    init(
        page: AuthenticationPage,
        navigationPath: Binding<NavigationPath>,
        output: Output? = nil
    ) {
        id = UUID()
        self.page = page
        self.output = output
        self._navigationPath = navigationPath
    }

    @ViewBuilder
    func view() -> some View {
        switch self.page {
            case .login:
                loginView()
            case .forgotPassword:
                forgotPasswordView()
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (
        lhs: HomeCoordinator,
        rhs: HomeCoordinator
    ) -> Bool {
        lhs.id == rhs.id
    }

    private func loginView() -> some View {
        let viewModel = HomeViewModel()
        let loginView = HomeView(
            viewModel: viewModel,
            output:
                .init(
                    goToMainScreen: {
                        self.output?.goToMainScreen()
                    },
                    goToForgotPassword:  {
                        self.push(
                            HomeCoordinator(
                                page: .forgotPassword,
                                navigationPath: self.$navigationPath
                            )
                        )
                    }
                )
        )
        return loginView
    }

    private func forgotPasswordView() -> some View {
        let viewModel = HomeViewModel()
        let loginView = HomeView(
            viewModel: viewModel,
            output:
                .init(
                    goToMainScreen: {
                        self.output?.goToMainScreen()
                    },
                    goToForgotPassword:  {
                        self.push(
                            HomeCoordinator(
                                page: .forgotPassword,
                                navigationPath: self.$navigationPath
                            )
                        )
                    }
                )
        )
        return loginView
    }

    private func goToForgotPasswordWebsite() {
        if let url = URL(string: "https://www.google.com") {
            UIApplication.shared.open(url)
        }
    }

    func push<V>(_ value: V) where V : Hashable {
        navigationPath.append(value)
    }
    
//    weak var delegate: CoordinatorDelegate?
//    var childCoordinator: Coordinator?
//    var viewController: UIViewController!
//    var navigationController: UINavigationController?
//    
//    @Published var navigationPath = NavigationPath()
//    
//    private var viewModel: HomeViewModel!
//    
//    init() {
//        viewModel = HomeViewModel()
//        self.navigationController = UINavigationController(rootViewController: UIHostingController(rootView: HomeView(viewModel:  .constant(self.viewModel))))
//        let view = HomeView(viewModel: .constant(self.viewModel))
//        let viewController = UIHostingController(rootView: view)
//        viewModel.coordinatorDelegate = self
//        navigationController?.pushViewController(viewController, animated: true)
//    }
//    
//    public func start() -> UIViewController {
//        viewModel = HomeViewModel()
//        let view = HomeView(viewModel:  .constant(self.viewModel))
//        let viewController = UIHostingController(rootView: view)
//        self.navigationController = UINavigationController(rootViewController: viewController)
//        viewModel.coordinatorDelegate = self
//        self.viewController = viewController
//        return viewController
//    }
//    
//    private func presentArticleDetail(with articleId: Int) {
//        let viewModel = ArticleDetailViewModel(articleId: articleId)
//        viewModel.coordinatorDelegate = self
//        let view = ArticleDetailView(viewModel: viewModel)
////        let viewController = UIHostingController(rootView: view)
////        viewController.modalPresentationStyle = .fullScreen
//        navigationPath.append(Route.articleDetail(articleId: viewModel.articleId))
//        
//        // TODO: Criar view model, view, view controller e setar modal presentation style para dar o present pela nv
//    }
}

enum Route: Hashable {
    case articleDetail(articleId: Int)
}

extension HomeCoordinator: HomeViewModelCoordinatorDelegate {
    func goToArticleDetail(articleId: Int) {
//        presentArticleDetail(with: articleId)
    }
}

extension HomeCoordinator: ArticleDetailViewModelCoordinatorDelegate {
    
}
