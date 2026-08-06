//
//  AuthenticationRegisterResponse.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

import Foundation

struct AuthenticationRegisterResponse: Decodable {
    let userId: UUID
    let email: String
    let verificationRequired: Bool?
    let message: String
    let retryAfterSeconds: Int
}
