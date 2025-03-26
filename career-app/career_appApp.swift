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
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appCoordinator.path) {
                appCoordinator.view()
                    .navigationDestination(
                        for: HomeCoordinator.self
                    ) { coordinator in
                        coordinator.view()
                    }
            }
            .environmentObject(appCoordinator)
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
