//
//  Coordinator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 04/03/25.
//

import SwiftUI
import Foundation // Para UUID, UserDefaults

/// Orquestrador raiz: só guarda o que é de verdade cross-cutting
/// (sessão/login, o NavigationPath compartilhado) e delega a navegação
/// de cada fluxo pro coordinator daquele fluxo (auth/track/profile/
/// videos). Home e Menu não têm coordinator próprio porque não são
/// donos de nenhuma tela — só disparam pushes nos coordinators abaixo.
@MainActor
final class Coordinator: ObservableObject {
    // Injetado uma vez em career_appApp — usado só para resetar a aba
    // selecionada para Home num login novo (ver isLoggedIn.didSet).
    // Isso precisa acontecer aqui, amarrado à transição de estado, e
    // não num .onAppear da ContentView: .onAppear dispara de novo
    // toda vez que se volta para a raiz depois de um push/pop
    // qualquer, o que resetava a aba errado ao simplesmente apertar
    // "voltar" em qualquer tela.
    weak var deepLinkManager: DeepLinkManager?

    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isUserLoggedIn")
            // Limpa o path quando o estado de login muda, forçando a raiz
            if isLoggedIn {
                // Se logou, limpa a pilha de navegação para iniciar um novo fluxo
                path = NavigationPath()
                deepLinkManager?.selectedTab = .home
                // Não faça push aqui, a buildRootView vai renderizar ContentView
            } else {
                // Se deslogou, limpa a pilha e remove o userId salvo
                path = NavigationPath()
                self.currentUserId = nil // Importante: limpa o ID ao deslogar
                UserDefaults.standard.removeObject(forKey: "currentUserId") // Remove do UserDefaults
            }
        }
    }

    // NOVO: Propriedade para armazenar o userId atualmente logado
    // Publicada para que outras views possam reagir a ela
    @Published var currentUserId: String? {
        didSet {
            // Persiste o userId sempre que ele muda
            if let id = currentUserId {
                UserDefaults.standard.set(id, forKey: "currentUserId")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUserId")
            }
        }
    }

    @Published var path: NavigationPath = NavigationPath()

    // Sub-coordinators — cada um cuida só da navegação do seu próprio
    // fluxo, mas todos empurram no `path` acima (um NavigationPath só,
    // pra não multiplicar NavigationStacks aninhadas dentro da TabView).
    let auth = AuthCoordinator()
    let track = TrackCoordinator()
    let profile = ProfileCoordinator()
    let videos = VideosCoordinator()

    // Exceção: tem NavigationPath própria porque não pode sair da aba
    // "Entrevistas" (ver InterviewAssistantCoordinator).
    let interviewAssistant = InterviewAssistantCoordinator()

    init() {
        // Inicializa isLoggedIn com o valor salvo
        _isLoggedIn = Published(initialValue: UserDefaults.standard.bool(forKey: "isUserLoggedIn"))
        // Inicializa currentUserId com o valor salvo
        _currentUserId = Published(initialValue: UserDefaults.standard.string(forKey: "currentUserId"))

        auth.root = self
        track.root = self
        profile.root = self
        videos.root = self
    }

    func push(_ route: RootRoute) {
        path.append(route)
    }

    func pop() {
        // NavigationPath.removeLast() dá precondition failure (crash) se o
        // path já estiver vazio. Isso é alcançável de verdade: com fluxos
        // async (ex.: submitForm aguardando uma chamada de rede antes de
        // decidir se navega), o usuário pode voltar manualmente (swipe/back)
        // enquanto a operação está em andamento, esvaziando o path antes
        // desse pop() programático rodar.
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count) // Mais seguro do que path = NavigationPath()
    }

    @ViewBuilder
    func buildRootView() -> some View {
        if isLoggedIn {
            ContentView(viewModel: .init(), listViewModel: self.track.jobApplicationTrackerListViewModel, userId: self.currentUserId)
        } else {
            self.auth.buildRootLoginView()
        }
    }

    /// Rotas que não pertencem a um fluxo só (ex.: artigo é aberto tanto
    /// pela Home quanto por Favoritos; créditos de IA e favoritos são
    /// telas únicas sem sub-navegação) — ficam direto no raiz em vez de
    /// forçar um coordinator de uma tela só.
    @ViewBuilder
    func build(_ route: RootRoute) -> some View {
        switch route {
        case .articleDetail(let id):
            ArticleDetailView(viewModel: .init(articleId: id))

        case .aiCredits:
            AICreditsView()

        case .favorites:
            FavoritesView(coordinator: self)
        }
    }

    func performLogout() {
        self.isLoggedIn = false // Isso limpa currentUserId via didSet
        currentUserId = ""
        UserDefaults.standard.removeObject(forKey: "authToken") // Certifique-se de que isso existe e está correto
        UserDefaults.standard.removeObject(forKey: "userId") // Remova se você usava isso antes, mas agora use currentUserId
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        AuthSession.shared.clear()
        self.popToRoot()
    }
}

enum RootRoute: Hashable {
    case articleDetail(id: Int)
    case aiCredits
    case favorites
}
