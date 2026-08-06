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
    let verificationRequired: Bool?
    let message: String?
    let username: String
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
