//
//  PasswordResetModels.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/08/26.
//

import Foundation

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ForgotPasswordResponse: Decodable {
    let message: String
}

struct VerifyPasswordResetCodeRequest: Encodable {
    let email: String
    let code: String
}

struct VerifyPasswordResetCodeResponse: Decodable {
    let resetToken: String
}

struct ResetPasswordRequest: Encodable {
    let resetToken: String
    let newPassword: String
}

struct ResetPasswordResponse: Decodable {
    let message: String
}
