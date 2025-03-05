//
//  AppDelegate.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 30/08/24.
//

import FirebaseCore
import SwiftUI

class DeepLinkManager: ObservableObject {
    @Published var selectedTab: TabSelection = .home
    
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "home":
            print("home selecionada")
            selectedTab = .home
        case "interview":
            print("interview selecionada")
            selectedTab = .interview
        case "tracker":
            print("tracker selecionada")
            selectedTab = .tracker
        case "menu":
            print("menu selecionada")
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

class AppDelegate: UIResponder, UIApplicationDelegate {
    var deepLinkManager = DeepLinkManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configurações globais do app
        FirebaseApp.configure()
        return true
    }
    
    // Adicione este método para suportar cenas
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        deepLinkManager.handleDeepLink(url: url)
        return true
    }
}
