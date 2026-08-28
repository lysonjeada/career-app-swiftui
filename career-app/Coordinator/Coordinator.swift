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

@MainActor
final class Coordinator: ObservableObject {
    // Injetado uma vez em career_appApp — usado só para resetar a aba
    // selecionada para Home num login novo (ver isLoggedIn.didSet).
    // Isso precisa acontecer aqui, amarrado à transição de estado, e
    // não num .onAppear da ContentView: .onAppear dispara de novo
    // toda vez que se volta para a raiz depois de um push/pop
    // qualquer, o que resetava a aba errado ao simplesmente apertar
    // "voltar" em qualquer tela.
    weak var deepLinkManager: DeepLinkManager?

    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isUserLoggedIn")
            // Limpa o path quando o estado de login muda, forçando a raiz
            if isLoggedIn {
                // Se logou, limpa a pilha de navegação para iniciar um novo fluxo
                path = NavigationPath()
                deepLinkManager?.selectedTab = .home
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

    // Compartilhado pelas 3 telas do fluxo de "esqueci minha senha"
    // (mesma ideia do jobApplicationTrackerListViewModel acima) — o
    // reset token emitido na verificação do código fica só em memória
    // aqui dentro, nunca precisa passar pelo AppPages/NavigationPath.
    var passwordResetViewModel = PasswordResetViewModel()
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
            }, onVerificationRequired: { email, username, password in
                self.push(
                    page:
                        .emailVerification(
                            email: email,
                            username: username,
                            password: password
                        )
                )
            })
        }
    }
    
    @ViewBuilder
    func build(page: AppPages) -> some View {
        switch page {
        case .main(let userId): // Este caso pode não ser mais necessário se buildRootView já lida com .main
            ContentView(viewModel: .init(), listViewModel: self.jobApplicationTrackerListViewModel, userId: userId)
            
        case .login:
            LoginView(
                viewModel: LoginViewModel(),
                onLoginSuccess: { userId in
                    self.currentUserId = userId
                    self.isLoggedIn = true
                    self.popToRoot()
                },
                onVerificationRequired: { email, username, password in
                    self.push(
                        page:
                                .emailVerification(
                                    email: email,
                                    username: username,
                                    password: password
                                )
                    )
                }
            )
            
        case .articleDetail(let id): ArticleDetailView(viewModel: .init(articleId: id))

        case .forgotPassword:
            ForgotPasswordView(
                viewModel: self.passwordResetViewModel,
                goToLogin: { self.push(page: .login) },
                onCodeSent: { self.push(page: .verifyPasswordResetCode) }
            )

        case .verifyPasswordResetCode:
            VerifyPasswordResetCodeView(
                viewModel: self.passwordResetViewModel,
                goBack: { self.pop() },
                onVerified: { self.push(page: .resetPassword) }
            )

        case .resetPassword:
            ResetPasswordView(
                viewModel: self.passwordResetViewModel,
                goToLogin: { self.goToLogin() }
            )

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

            SignUpView(
                viewModel: signUpViewModel,
                goToLogin: {
                    self.pop()
                },
                onVerificationRequired: { email, username, password in
                    self.push(
                        page: .emailVerification(
                            email: email,
                            username: username,
                            password: password
                        )
                    )
                }
            )
        case let .emailVerification(email, username, password):
            EmailVerificationView(
                email: email,
                onVerified: {
                    self.completeVerifiedLogin(
                        username: username,
                        password: password
                    )
                },
                goBack: {
                    self.pop()
                }
            )
        case .videos:
            VideosView(
                coordinator: self
            )

        case .uploadVideo:
            UploadVideoView(
                coordinator: self
            )

        case let .videoDetail(
            videoId
        ):
            VideoDetailView(
                videoId: videoId,
                coordinator: self
            )

        case .aiCredits:
            AICreditsView()

        case .favorites:
            FavoritesView(
                coordinator: self
            )
        }
    }
    
    func performLogout() {
        self.isLoggedIn = false // Isso limpa currentUserId via didSet
        currentUserId = ""
        UserDefaults.standard.removeObject(forKey: "authToken") // Certifique-se de que isso existe e está correto
        UserDefaults.standard.removeObject(forKey: "userId") // Remova se você usava isso antes, mas agora use currentUserId
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        AuthSession.shared.clear()
        self.popToRoot()
    }
    
    @MainActor
    private func goToLogin() {
        path = NavigationPath()

        push(
            page: .login
        )
    }

    /// Faz o login automaticamente com as credenciais recém-digitadas
    /// assim que o código de verificação é confirmado — evita mandar o
    /// usuário de volta para a tela de login logo depois de cadastrar
    /// ou verificar a conta.
    @MainActor
    private func completeVerifiedLogin(
        username: String,
        password: String
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await AuthenticationService()
                    .fetchLogin(
                        requestBody: .init(
                            username: username,
                            password: password
                        )
                    )

                AuthSession.shared.save(response: response)

                self.currentUserId = response.id.uuidString
                self.isLoggedIn = true

            } catch {
                // A conta já foi verificada; se o login automático
                // falhar (ex.: instabilidade de rede), o usuário ainda
                // consegue entrar manualmente com as mesmas credenciais.
                self.goToLogin()
            }
        }
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
    case verifyPasswordResetCode
    case resetPassword
    case emailVerification(
        email: String,
        username: String,
        password: String
    )
    case videos
    case uploadVideo
    case videoDetail(
        videoId: String
    )
    case aiCredits
    case favorites
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


