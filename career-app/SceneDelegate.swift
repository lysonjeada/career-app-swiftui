//
//  SceneDelegate.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 01/03/25.
//

import UIKit
import SwiftUI

//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//    var window: UIWindow?
//    var appCoordinator: Coordinator?
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        window = UIWindow(frame: UIScreen.main.bounds)
//        
//        // Cria uma instância do CareerAppModule
//        let careerAppModule = CareerAppModule()
//        
//        // Obtém o Coordinator inicial (por exemplo, o HomeCoordinator)
//        if let initialCoordinator = careerAppModule.coordinator(for: FlowLocation(path: "home")) {
//            appCoordinator = initialCoordinator
//            
//            window?.rootViewController = initialCoordinator.start()
//            window?.makeKeyAndVisible()
//        }
////        window = UIWindow(windowScene: windowScene)
////        let viewModel = HomeViewModel()
////        let controller = UIHostingController(rootView: HomeView(viewModel: viewModel))
////        window?.rootViewController = controller
////        window?.makeKeyAndVisible()
//    }
//}
