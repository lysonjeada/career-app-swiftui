//
//  AuthenticationServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class AuthenticationServiceMock: AuthenticationServiceProtocol {
    var isSuccess: Bool
    var errorToThrow: Error?
    private(set) var receivedRegisterRequest: AuthenticationRegisterRequest?
    private(set) var receivedLoginRequest: AuthenticationLoginRequest?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func createRegister(requestBody: AuthenticationRegisterRequest) async throws -> AuthenticationRegisterResponse {
        receivedRegisterRequest = requestBody

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("authentication-register-response")
    }

    func fetchLogin(requestBody: AuthenticationLoginRequest) async throws -> AuthenticationLoginResponse {
        receivedLoginRequest = requestBody

        if let errorToThrow {
            throw errorToThrow
        }

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("login-success-response")
    }
}
