//
//  CareerAppExampleApp.swift
//  CareerAppExample
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import SwiftUI

@main
struct CareerAppExampleApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
