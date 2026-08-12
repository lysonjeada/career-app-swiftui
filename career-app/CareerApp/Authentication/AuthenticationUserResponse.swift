//
//  AuthenticationUserResponse.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 11/08/26.
//

import Foundation

struct AuthenticationUserResponse:
    Decodable {
    let id: UUID
    let email: String
    let username: String
    let isActive: Bool
    let isEmailVerified: Bool
}
