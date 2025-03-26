//
//  CoordinatorView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/03/25.
//

import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .main)
                .navigationDestination(for: AppPages.self) { page in
                    coordinator.build(page: page)
                }
//                .sheet(item: $coordinator.sheet) { sheet in
//                    coordinator.buildSheet(sheet: sheet)
//                }
//                .fullScreenCover(item: $coordinator.fullScreenCover) { item in
//                    coordinator.buildCover(cover: item)
//                }
        }
        .environmentObject(coordinator)
    }
}
