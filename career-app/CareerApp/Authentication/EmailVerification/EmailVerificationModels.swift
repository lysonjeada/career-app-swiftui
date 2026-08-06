//
//  EmailVerificationModels.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

import Foundation

struct EmailVerificationRequest: Encodable {
    let email: String
    let code: String
}

struct EmailVerificationResponse: Decodable {
    let verified: Bool
    let message: String
}

struct ResendEmailVerificationRequest:
    Encodable {

    let email: String
}

struct ResendEmailVerificationResponse:
    Decodable {

    let message: String
    let retryAfterSeconds: Int
}
