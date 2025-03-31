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
//        let viewModel = HomeViewModel()
//        let loginView = HomeView(
//            viewModel: viewModel,
//            output:
//                .init(
//                    goToMainScreen: {
//                        self.output?.goToMainScreen()
//                    },
//                    goToForgotPassword:  {
//                        self.push(
//                            HomeCoordinator(
//                                page: .forgotPassword,
//                                navigationPath: self.$navigationPath
//                            )
//                        )
//                    }
//                )
//        )
        let loginView = LoginView()
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
