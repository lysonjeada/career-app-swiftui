//
//  AppCoordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 26/03/25.
//

import SwiftUI

final class AppCoordinator: ObservableObject {
    @Published var path: NavigationPath

    init(path: NavigationPath) {
        self.path = path
    }

    @ViewBuilder
    func view() -> some View {
        MainView()
    }
}
