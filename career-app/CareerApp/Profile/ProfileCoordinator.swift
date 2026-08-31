//
//  ProfileCoordinator.swift
//  career-app
//

import SwiftUI

/// Navegação do fluxo de perfil — empurra no `path` compartilhado do
/// Coordinator raiz. `performLogout()` é repassado pro raiz porque é
/// estado de sessão, não de navegação de uma feature só.
@MainActor
final class ProfileCoordinator {
    weak var root: Coordinator?

    func push(_ route: ProfileRoute) {
        root?.path.append(route)
    }

    func pop() {
        root?.pop()
    }

    func performLogout() {
        root?.performLogout()
    }

    @ViewBuilder
    func build(_ route: ProfileRoute) -> some View {
        switch route {
        case .profile(let userId):
            ProfileView(userId: userId, coordinator: self, viewModel: ProfileViewModel())
        }
    }
}

enum ProfileRoute: Hashable {
    case profile(userId: String?)
}
