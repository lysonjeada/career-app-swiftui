//
//  AICreditsServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class AICreditsServiceMock: AICreditsServiceProtocol {
    var isSuccess: Bool
    var balanceToReturn: Int
    var purchaseResultToReturn: AICreditPurchaseResult
    private(set) var fetchBalanceCallCount = 0
    private(set) var receivedSignedTransaction: String?
    private(set) var receivedProductID: String?

    init(
        isSuccess: Bool,
        balanceToReturn: Int = 0,
        purchaseResultToReturn: AICreditPurchaseResult = AICreditPurchaseResult(
            creditsAdded: 0,
            balance: 0,
            alreadyProcessed: false
        )
    ) {
        self.isSuccess = isSuccess
        self.balanceToReturn = balanceToReturn
        self.purchaseResultToReturn = purchaseResultToReturn
    }

    func fetchBalance() async throws -> Int {
        fetchBalanceCallCount += 1

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return balanceToReturn
    }

    func registerApplePurchase(
        signedTransaction: String,
        productID: String
    ) async throws -> AICreditPurchaseResult {
        receivedSignedTransaction = signedTransaction
        receivedProductID = productID

        guard isSuccess else {
            throw URLError(.badServerResponse)
        }

        return purchaseResultToReturn
    }
}
