//
//  Loadable.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

enum Loadable<T>: Equatable where T: Equatable {
    case idle
    case loading
    case loaded(T)
    case failed(Error)

    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.loaded(let l), .loaded(let r)):
            return l == r
        case (.failed, .failed):
            return true // você pode refinar isso com tipos de erro
        default:
            return false
        }
    }
}

extension Loadable {
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
}
