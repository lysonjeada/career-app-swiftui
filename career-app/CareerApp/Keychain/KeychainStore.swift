//
//  KeychainStore.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation
import Security

enum KeychainStore {
    static func save(
        _ value: String,
        key: String
    ) {
        let data =
            Data(value.utf8)

        let query:
            [String: Any] = [
                kSecClass as String:
                    kSecClassGenericPassword,

                kSecAttrAccount as String:
                    key
            ]

        SecItemDelete(
            query as CFDictionary
        )

        var attributes =
            query

        attributes[
            kSecValueData as String
        ] = data

        attributes[
            kSecAttrAccessible as String
        ] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        SecItemAdd(
            attributes as CFDictionary,
            nil
        )
    }

    static func read(
        key: String
    ) -> String? {
        let query:
            [String: Any] = [
                kSecClass as String:
                    kSecClassGenericPassword,

                kSecAttrAccount as String:
                    key,

                kSecReturnData as String:
                    true,

                kSecMatchLimit as String:
                    kSecMatchLimitOne
            ]

        var result:
            CFTypeRef?

        let status =
            SecItemCopyMatching(
                query as CFDictionary,
                &result
            )

        guard
            status == errSecSuccess,
            let data =
                result as? Data
        else {
            return nil
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }

    static func delete(
        key: String
    ) {
        let query:
            [String: Any] = [
                kSecClass as String:
                    kSecClassGenericPassword,

                kSecAttrAccount as String:
                    key
            ]

        SecItemDelete(
            query as CFDictionary
        )
    }
}
