//
//  AICreditsService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import Foundation

struct AICreditPurchaseResult: Decodable, Equatable {
    let creditsAdded: Int
    let balance: Int
    let alreadyProcessed: Bool

    enum CodingKeys: String, CodingKey {
        case creditsAdded = "credits_added"
        case balance
        case alreadyProcessed = "already_processed"
    }
}

protocol AICreditsServiceProtocol {
    func fetchBalance() async throws -> Int

    func registerApplePurchase(
        signedTransaction: String,
        productID: String
    ) async throws -> AICreditPurchaseResult
}

final class AICreditsService: AICreditsServiceProtocol {

    func fetchBalance() async throws -> Int {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)/ai-credits/balance"
        ) else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await AuthenticatedHTTPClient.shared.data(
            for: request
        )

        try Self.validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(
            BalanceResponse.self,
            from: data
        )

        return decoded.balance
    }

    func registerApplePurchase(
        signedTransaction: String,
        productID: String
    ) async throws -> AICreditPurchaseResult {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)/ai-credits/apple/purchases"
        ) else {
            throw APIError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let payload = ApplePurchaseRequestBody(
            signedTransaction: signedTransaction,
            productId: productID
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await AuthenticatedHTTPClient.shared.data(
            for: request
        )

        try Self.validate(response: response, data: data)

        return try JSONDecoder().decode(
            AICreditPurchaseResult.self,
            from: data
        )
    }

    private static func validate(
        response: URLResponse,
        data: Data
    ) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.from(
                statusCode: httpResponse.statusCode,
                data: data
            )
        }
    }
}

private struct BalanceResponse: Decodable {
    let balance: Int
}

private struct ApplePurchaseRequestBody: Encodable {
    let signedTransaction: String
    let productId: String

    enum CodingKeys: String, CodingKey {
        case signedTransaction = "signed_transaction"
        case productId = "product_id"
    }
}
