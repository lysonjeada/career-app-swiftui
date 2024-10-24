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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        logSeeInicialScreenEvent()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
