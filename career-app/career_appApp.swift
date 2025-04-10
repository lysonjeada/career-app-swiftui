//
//  career_appApp.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 12/08/24.
//

import SwiftUI
import FirebaseAnalytics

@main
struct career_appApp: App {
    @StateObject private var appCoordinator = AppCoordinator(path: NavigationPath())
    @StateObject private var coordinator = Coordinator()
    @StateObject private var deepLinkManager = DeepLinkManager()
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .environmentObject(coordinator)
                .environmentObject(deepLinkManager)
        }
    }
    
    func logSeeInicialScreenEvent() {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id",
            AnalyticsParameterItemName: "viu-tela-inicial",
            AnalyticsParameterContentType: "cont",
        ])
    }
}
