//
//  AppDelegate.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 30/08/24.
//

import FirebaseCore
import SwiftUI

class DeepLinkManager: ObservableObject {
    @Published var selectedTab: TabSelection = .home {
        didSet {
            updateTitle()
        }
    }
    
    @Published var title: String = "Login"
    
    private func updateTitle() {
        switch selectedTab {
        case .home:
            title = "TechStep"
        case .interview:
            title = "Entrevistas"
        case .tracker:
            title = "Tracker"
        case .menu:
            title = "Menu"
        }
    }
    
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "home":
            print("home selecionada")
            title = "HOME"
            selectedTab = .home
        case "interview":
            print("interview selecionada")
            title = "ENTREVISTAS"
            selectedTab = .interview
        case "tracker":
            print("tracker selecionada")
            title = "TRACKER"
            selectedTab = .tracker
        case "menu":
            print("menu selecionada")
            title = "MENU"
            selectedTab = .menu
        default:
            break
        }
    }
}
    
    enum TabSelection: Hashable {
        case home
        case interview
        case tracker
        case menu
    }
    
    //class AppDelegate: UIResponder, UIApplicationDelegate {
    //    var window: UIWindow?
    //    var appCoordinator: Coordinator?
    //    let navigationController = UINavigationController()
    //    var homeCoordinator: HomeCoordinator?
    //
    //    var deepLinkManager = DeepLinkManager()
    //
    //    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    //        // Configurações globais do app
    //        FirebaseApp.configure()
    //        window = UIWindow(frame: UIScreen.main.bounds)
    //
    //        // Cria o HomeCoordinator e mantém uma referência forte
    //        homeCoordinator = HomeCoordinator()
    //
    //        // Define o viewController inicial
    //        if let viewController = homeCoordinator?.start() {
    //            window?.rootViewController = viewController
    //        }
    //
    //        // Torna a janela visível
    //        window?.makeKeyAndVisible()
    //
    //        return true
    //
    //        //        let careerAppModule = CareerAppModule()
    //        //
    //        //        // Obtém o Coordinator inicial (por exemplo, o HomeCoordinator)
    //        //        if let initialCoordinator = careerAppModule.coordinator(for: FlowLocation(path: "home")) {
    //        //            appCoordinator = initialCoordinator
    //        //
    //        //            window?.rootViewController = initialCoordinator.start()
    //        //            window?.makeKeyAndVisible()
    //        //        }
    //    }
    //
    //    // Adicione este método para suportar cenas
    //    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    //        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    //    }
    //
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        deepLinkManager.handleDeepLink(url: url)
    //        return true
    //    }
    //}
