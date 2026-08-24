//
//  ProfileServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var isSuccess: Bool
    private(set) var receivedFetchUserId: String?
    private(set) var receivedDeleteUserId: String?

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func deleteUser(userId: String) async throws {
        receivedDeleteUserId = userId

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }
    }
    
    func fetchProfile(userId: String) async throws -> career_app.AuthenticationUserResponse {
        receivedFetchUserId = userId

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return try JSONLoader.load("authentication-login-response")
    }
}
