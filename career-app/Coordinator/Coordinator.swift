//
//  Coordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import UIKit
import SwiftUI

import SwiftUI
import Foundation // Para UUID, UserDefaults
import FirebaseAnalytics // Se você usa

// ... AppPages, Route, Sheet, FullScreenCover definitions ...

final class Coordinator: ObservableObject {
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isUserLoggedIn")
            // Limpa o path quando o estado de login muda, forçando a raiz
            if isLoggedIn {
                // Se logou, limpa a pilha de navegação para iniciar um novo fluxo
                path = NavigationPath()
                // Não faça push aqui, a buildRootView vai renderizar ContentView
            } else {
                // Se deslogou, limpa a pilha e remove o userId salvo
                path = NavigationPath()
                self.currentUserId = nil // Importante: limpa o ID ao deslogar
                UserDefaults.standard.removeObject(forKey: "currentUserId") // Remove do UserDefaults
            }
        }
    }
    
    // NOVO: Propriedade para armazenar o userId atualmente logado
    // Publicada para que outras views possam reagir a ela
    @Published var currentUserId: String? {
        didSet {
            // Persiste o userId sempre que ele muda
            if let id = currentUserId {
                UserDefaults.standard.set(id, forKey: "currentUserId")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserId")
            }
        }
    }
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    var jobApplicationTrackerListViewModel = JobApplicationTrackerListViewModel()
    // O LoginViewModel deve ser instanciado aqui no Coordinator
    // e passado para a LoginView no buildRootView
    var loginViewModel = LoginViewModel()
    
    init() {
        // Inicializa isLoggedIn com o valor salvo
        _isLoggedIn = Published(initialValue: UserDefaults.standard.bool(forKey: "isUserLoggedIn"))
        // Inicializa currentUserId com o valor salvo
        _currentUserId = Published(initialValue: UserDefaults.standard.string(forKey: "currentUserId"))
    }
    
    func push(page: AppPages) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count) // Mais seguro do que path = NavigationPath()
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
            ContentView(viewModel: .init(), listViewModel: self.jobApplicationTrackerListViewModel, userId: self.currentUserId)
        } else {
            LoginView(viewModel: self.loginViewModel, onLoginSuccess: { [weak self] userId in
                self?.currentUserId = userId
                self?.isLoggedIn = true
            })
        }
    }
    
    @ViewBuilder
    func build(page: AppPages) -> some View {
        switch page {
        case .main(let userId): // Este caso pode não ser mais necessário se buildRootView já lida com .main
            ContentView(viewModel: .init(), listViewModel: self.jobApplicationTrackerListViewModel, userId: userId)
            
        case .login:
            // Se você puder "pushar" para login (ex: de uma tela de "sessão expirada"),
            // Certifique-se de que o callback de sucesso atualize o coordinator.currentUserId
            LoginView(viewModel: self.loginViewModel, onLoginSuccess: { [weak self] userId in
                self?.currentUserId = userId
                self?.isLoggedIn = true
                // Não precisa de push, o didSet de isLoggedIn já fará a HomeView aparecer como raiz
            })
            
        case .articleDetail(let id): ArticleDetailView(viewModel: .init(articleId: id))
        case .profile(let userId):
            let profileViewModel = ProfileViewModel()
            ProfileView(userId: userId, coordinator: self, viewModel: profileViewModel)
            
        case .addJob:
            AddJobApplicationForm(viewModel: self.jobApplicationTrackerListViewModel, coordinator: self)
        case .editJob(let job):
            EditJobApplicationView(job: job, coordinator: self, viewModel: self.jobApplicationTrackerListViewModel)
        case .listApplications:
            JobApplicationTrackerView(listViewModel: self.jobApplicationTrackerListViewModel, coordinator: self)
        case .signUp:
            let signUpViewModel = SignUpViewModel()
            SignUpView(viewModel: signUpViewModel, goToLogin: { self.push(page: .login) } , onRegister: {
                // Se o registro retorna um userId, salve-o e logue o usuário
                self.currentUserId = ""
//                self.isLoggedIn = true
            })
        case .forgotPassword:
            ForgotPasswordView(goToLogin: { self.push(page: .login) } )
        }
    }
    
    func performLogout() {
        self.isLoggedIn = false // Isso limpa currentUserId via didSet
        
        UserDefaults.standard.removeObject(forKey: "authToken") // Certifique-se de que isso existe e está correto
        UserDefaults.standard.removeObject(forKey: "userId") // Remova se você usava isso antes, mas agora use currentUserId
        
        self.popToRoot()
    }
}

enum AppPages: Hashable {
    case main(userId: String?)
    case login
    case articleDetail(id: Int)
    case listApplications
    case profile(userId: String?)
    case addJob
    case editJob(JobApplication)
    case signUp
    case forgotPassword
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


