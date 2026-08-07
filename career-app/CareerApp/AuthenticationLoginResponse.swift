//
//  AuthenticationLoginResponse.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 19/07/25.
//

import Foundation

struct AuthenticationLoginResponse: Decodable {
    let id: UUID
    let email: String
    let username: String
    let isActive: Bool
    let isEmailVerified: Bool
    let createdAt: String
    let updatedAt: String
    let accessToken: String
    let tokenType: String
}

struct AuthenticationStringErrorResponse: Decodable {
    let detail: String
}

struct AuthenticationObjectErrorResponse: Decodable {
    let detail: AuthenticationErrorDetail
}

struct AuthenticationErrorDetail: Decodable {
    let code: String
    let message: String
    let email: String?
}
