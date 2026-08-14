//
//  AuthSession.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 11/08/26.
//

import Foundation

final class AuthSession {
    static let shared =
        AuthSession()

    private enum Keys {
        static let accessToken =
            "auth_access_token"

        static let refreshToken =
            "auth_refresh_token"

        static let userId =
            "auth_user_id"
    }

    private init() {}

    var accessToken: String? {
        KeychainStore.read(
            key: Keys.accessToken
        )
    }

    var refreshToken: String? {
        KeychainStore.read(
            key: Keys.refreshToken
        )
    }

    var userId: String? {
        UserDefaults.standard.string(
            forKey: Keys.userId
        )
    }

    var isAuthenticated: Bool {
        guard let refreshToken,
              !refreshToken.isEmpty
        else {
            return false
        }

        return true
    }

    func save(
        response:
            AuthenticationLoginResponse
    ) {
        saveTokens(
            accessToken:
                response.accessToken,
            refreshToken:
                response.refreshToken
        )

        UserDefaults.standard.set(
            response.id.uuidString,
            forKey: Keys.userId
        )
    }

    func saveTokens(
        accessToken: String,
        refreshToken: String
    ) {
        KeychainStore.save(
            accessToken,
            key: Keys.accessToken
        )

        KeychainStore.save(
            refreshToken,
            key: Keys.refreshToken
        )
    }

    func clear() {
        KeychainStore.delete(
            key: Keys.accessToken
        )

        KeychainStore.delete(
            key: Keys.refreshToken
        )

        UserDefaults.standard.removeObject(
            forKey: Keys.userId
        )
    }
}
