//
//  SceneDelegate.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 01/03/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewModel = HomeViewModel()
        let controller = UIHostingController(rootView: HomeView(viewModel: viewModel))
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }
}
