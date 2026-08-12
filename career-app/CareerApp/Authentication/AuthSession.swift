//
//  AuthSession.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 11/08/26.
//

import Foundation

final class AuthSession {
    static let shared = AuthSession()

    private enum Keys {
        static let accessToken =
            "auth_access_token"

        static let userId =
            "auth_user_id"
    }

    private init() {}

    var accessToken: String? {
        UserDefaults.standard.string(
            forKey: Keys.accessToken
        )
    }

    var userId: String? {
        UserDefaults.standard.string(
            forKey: Keys.userId
        )
    }

    var isAuthenticated: Bool {
        guard let accessToken,
              !accessToken.isEmpty
        else {
            return false
        }

        return true
    }

    func save(
        response: AuthenticationLoginResponse
    ) {
        print(
            """
            💾 Salvando AuthSession...
            Token recebido: \(response.accessToken)
            """
        )

        UserDefaults.standard.set(
            response.accessToken,
            forKey: Keys.accessToken
        )

        UserDefaults.standard.set(
            response.id.uuidString,
            forKey: Keys.userId
        )

        print(
            """
            ✅ AuthSession salva
            Token salvo: \(accessToken ?? "SEM TOKEN")
            User ID salvo: \(userId ?? "SEM USER ID")
            """
        )
    }

    func clear() {
        UserDefaults.standard.removeObject(
            forKey: Keys.accessToken
        )

        UserDefaults.standard.removeObject(
            forKey: Keys.userId
        )
    }
}
