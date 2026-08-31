//
//  PurchaseService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import StoreKit

/// Representação de uma transação StoreKit já verificada, desacoplada
/// de `StoreKit.Transaction`/`Product` (que não têm inicializador
/// público, então não dá para criar um fake em testes/Previews). O
/// `finish` closure encapsula `transaction.finish()` sem expor o tipo
/// real do SDK para quem consome (AICreditsViewModel,
/// AICreditsTransactionObserver).
struct VerifiedTransaction {
    let jwsRepresentation: String
    let productID: String
    let finish: () async -> Void
}

enum PurchaseResult {
    case success(VerifiedTransaction)
    case pending
    case userCancelled
}

enum PurchaseServiceError: LocalizedError {
    case verificationFailed
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Não foi possível verificar a compra com a Apple."
        case .productNotFound:
            return "Produto não encontrado na App Store."
        }
    }
}

protocol PurchaseServiceProtocol {
    /// Retorna já mapeado para `AICreditPackageDisplay` — o ViewModel
    /// não deveria enxergar `StoreKit.Product` (que sequer tem
    /// inicializador público, então não dá para fabricar um fake em
    /// testes/Previews) só para exibir id/preço.
    func fetchProducts() async throws -> [AICreditPackageDisplay]

    /// Busca o `Product` correspondente a `productID` e inicia a
    /// compra — a resolução do `Product` real do StoreKit fica aqui
    /// (não no ViewModel), que só conhece o ID.
    func purchase(productID: String) async throws -> PurchaseResult

    /// Observa StoreKit.Transaction.updates pela vida inteira do app —
    /// usado para reconciliar compras aprovadas pela Apple que não
    /// chegaram a ser confirmadas no backend (ex.: app fechado logo
    /// após a compra).
    func observeTransactionUpdates(
        onUpdate: @escaping (VerifiedTransaction) async -> Void
    ) -> Task<Void, Never>

    /// Transações que a Apple já aprovou mas o app ainda não chamou
    /// `finish()` — checadas no launch, além do stream de updates.
    func unfinishedTransactions() async -> [VerifiedTransaction]
}

final class PurchaseService: PurchaseServiceProtocol {

    func fetchProducts() async throws -> [AICreditPackageDisplay] {
        try await Product.products(
            for: AICreditProduct.allProductIDs
        )
        .compactMap(AICreditPackageDisplay.init(product:))
    }

    func purchase(productID: String) async throws -> PurchaseResult {
        guard let product = try await Product.products(
            for: [productID]
        ).first else {
            throw PurchaseServiceError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case let .success(verification):
            return .success(
                try Self.verifiedTransaction(from: verification)
            )

        case .pending:
            return .pending

        case .userCancelled:
            return .userCancelled

        @unknown default:
            return .pending
        }
    }

    func observeTransactionUpdates(
        onUpdate: @escaping (VerifiedTransaction) async -> Void
    ) -> Task<Void, Never> {
        Task.detached {
            for await update in StoreKit.Transaction.updates {
                guard let verified = try? Self.verifiedTransaction(
                    from: update
                ) else {
                    continue
                }

                await onUpdate(verified)
            }
        }
    }

    func unfinishedTransactions() async -> [VerifiedTransaction] {
        var transactions: [VerifiedTransaction] = []

        for await result in StoreKit.Transaction.unfinished {
            if let verified = try? Self.verifiedTransaction(from: result) {
                transactions.append(verified)
            }
        }

        return transactions
    }

    private static func verifiedTransaction(
        from result: VerificationResult<StoreKit.Transaction>
    ) throws -> VerifiedTransaction {
        switch result {
        case .unverified:
            throw PurchaseServiceError.verificationFailed

        case let .verified(transaction):
            return VerifiedTransaction(
                jwsRepresentation: result.jwsRepresentation,
                productID: transaction.productID,
                finish: { await transaction.finish() }
            )
        }
    }
}

extension AICreditPackageDisplay {
    init?(product: Product) {
        guard let creditProduct = AICreditProduct(
            rawValue: product.id
        ) else {
            return nil
        }

        self.init(
            id: product.id,
            credits: creditProduct.credits,
            priceText: product.displayPrice
        )
    }
}
