//
//  AuthenticationLoginResponse.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

struct AuthenticationLoginResponse: Decodable, Identifiable {
    let id: UUID
    let email: String
    var username: String
    let is_active: Bool
}
