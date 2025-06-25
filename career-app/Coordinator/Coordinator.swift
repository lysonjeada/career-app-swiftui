//
//  Coordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import UIKit
import SwiftUI

class Coordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published var isLoggedIn: Bool = false
    
    func push(page: AppPages) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.fullScreenCover = nil
    }
    
    @ViewBuilder
    func buildRootView() -> some View {
        if isLoggedIn {
            ContentView(viewModel: .init()) // Sua TabView principal
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    func build(page: AppPages) -> some View {
        switch page {
        case .main: ContentView(viewModel: .init())
            /*HomeView(viewModel: .init(), output: .init(goToMainScreen: { }, goToForgotPassword: { }))*/
        case .login: LoginView()
        case .articleDetail(let id): ArticleDetailView(viewModel: .init(articleId: id))
        case .profile:
            ProfileView(coordinator: self)
        case .addJob:
            AddJobApplicationForm(newCompany: .constant(""), newLevel: .constant(""), newLastInterview: .constant(""), newNextInterview: .constant(""), newTechnicalSkills: .constant(""))
        case .editJob:
            EditJobApplicationView(company: .constant(""), level: .constant(""), lastInterview: .constant(""), nextInterview: .constant(""), technicalSkills: .constant(""), coordinator: self)
        }
    }
    
}

enum AppPages: Hashable {
    case main
    case login
    case articleDetail(id: Int)
    case profile
    case addJob
    case editJob
    //    case addJob(newCompany: String,
    //                newLevel: String,
    //                newLastInterview: String,
    //                newNextInterview: String,
    //                newTechnicalSkills: String)
}

enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case forgotPassword
}

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case signup
}

//public protocol Coordinator: CoordinatorDelegate {
//    var delegate: CoordinatorDelegate? { get set }
//    var childCoordinator: Coordinator? { get set }
//    var viewController: UIViewController! { get set }
//    var navigationController: UINavigationController? { get set }
//    var modulePath: String? { get }
//
//    func start() -> UIViewController
//    func start(usingPresenter presenter: CoordinatorPresenter, animated: Bool)
//}
//
//extension Coordinator {
//
//    public var modulePath: String? { nil }
//
//    public func start() -> UIViewController {
//        let coordinator = HomeCoordinator()
//        coordinator.delegate = self
//        coordinator.navigationController = navigationController
//        coordinator.childCoordinator = childCoordinator
//        return coordinator.start()
//
////        let viewModel = HomeViewModel()
////        viewModel.coordinatorDelegate = HomeCoordinator.
////        let view = HomeView(viewModel: viewModel)
////        let viewController = UIHostingController(rootView: view)
////        //        viewModel.coordinatorDelegate = self
////        //        self.viewController = viewController
////        return viewController
//    }
//
//    public func start(usingPresenter presenter: CoordinatorPresenter, animated: Bool = false) {
//        performStart(usingPresenter: presenter, animated: animated)
//    }
//
//    public func performStart(usingPresenter presenter: CoordinatorPresenter, animated: Bool) {
//        guard viewController != nil else {
//            assertionFailure("view controller is null when pushing")
//            return
//        }
//        navigationController = presenter.present(destiny: viewController, animated: animated)
//    }
//
//    public func route(to coordinator: Coordinator,
//                      withPresenter presenter: CoordinatorPresenter,
//                      animated: Bool = true,
//                      delegate: CoordinatorDelegate? = nil) {
//        childCoordinator = coordinator
//        coordinator.delegate = delegate ?? self
//        coordinator.start(usingPresenter: presenter, animated: animated)
//    }
//}


