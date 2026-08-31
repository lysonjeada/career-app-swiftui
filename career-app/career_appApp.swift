//
//  career_appApp.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 12/08/24.
//

import SwiftUI
import FirebaseAnalytics
import CoreData

@main
struct career_appApp: App {
    @StateObject private var coordinator = Coordinator()
    @StateObject private var deepLinkManager = DeepLinkManager()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(coordinator)
                .environmentObject(deepLinkManager)
                .onAppear {
                    coordinator.deepLinkManager = deepLinkManager
                }
                .task {
                    // Observa compras de créditos de IA aprovadas pela
                    // Apple mas nunca confirmadas no backend (app
                    // fechado logo após a compra, queda de rede) pela
                    // vida inteira do app.
                    await AICreditsTransactionObserver.shared.start()
                }
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

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CareerApp") // Substitua pelo nome do seu .xcdatamodeld
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Erro ao carregar Core Data: \(error.localizedDescription)")
            }
        }
    }
}
