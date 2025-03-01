//
//  AppDelegate.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 30/08/24.
//

import FirebaseCore
import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
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
        // Extrai o host (tela) e os parâmetros do URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return false
        }
        
        // Exemplo: meuapp://produto/123
        if host == "produto", let productID = components.path.split(separator: "/").last {
            print("Abrindo tela do produto com ID: \(productID)")
            // Navegue para a tela do produto
            return true
        }
        
        return false
    }
}
