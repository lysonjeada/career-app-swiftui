//
//  RefreshTokenRequest.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

struct RefreshTokenRequest:
    Encodable {

    let refreshToken: String
}


struct TokenRefreshResponse:
    Decodable {

    let accessToken: String
    let refreshToken: String

    let tokenType: String
    let expiresIn: Int
}
