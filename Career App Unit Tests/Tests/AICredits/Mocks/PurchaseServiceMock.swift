//
//  PurchaseServiceMock.swift
//  career-app
//

@testable import career_app
import Foundation

final class PurchaseServiceMock: PurchaseServiceProtocol {
    var productsToReturn: [AICreditPackageDisplay] = []
    var productsError: Error?
    var purchaseResultToReturn: PurchaseResult = .userCancelled
    var purchaseError: Error?
    var unfinishedTransactionsToReturn: [VerifiedTransaction] = []

    private(set) var receivedPurchaseProductID: String?
    private(set) var purchaseCallCount = 0

    func fetchProducts() async throws -> [AICreditPackageDisplay] {
        if let productsError {
            throw productsError
        }

        return productsToReturn
    }

    func purchase(productID: String) async throws -> PurchaseResult {
        purchaseCallCount += 1
        receivedPurchaseProductID = productID

        if let purchaseError {
            throw purchaseError
        }

        return purchaseResultToReturn
    }

    func observeTransactionUpdates(
        onUpdate: @escaping (VerifiedTransaction) async -> Void
    ) -> Task<Void, Never> {
        Task {}
    }

    func unfinishedTransactions() async -> [VerifiedTransaction] {
        unfinishedTransactionsToReturn
    }
}

extension VerifiedTransaction {
    /// Helper de teste: `StoreKit.Transaction` não tem inicializador
    /// público, então `VerifiedTransaction` foi desenhado para nunca
    /// precisar de um — só precisa do JWS, do product id, e de uma
    /// forma de observar se `finish()` foi chamado.
    static func fake(
        jwsRepresentation: String = "fake-jws",
        productID: String = AICreditProduct.thirty.rawValue,
        onFinish: @escaping () -> Void = {}
    ) -> VerifiedTransaction {
        VerifiedTransaction(
            jwsRepresentation: jwsRepresentation,
            productID: productID,
            finish: { onFinish() }
        )
    }
}
