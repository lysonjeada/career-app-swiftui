//
//  AICreditsTransactionObserver.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import StoreKit

/// Observa StoreKit.Transaction.updates durante toda a vida do app
/// (iniciado no launch, em career_appApp) e reconcilia transações
/// pendentes já aprovadas pela Apple — garante que uma compra
/// aprovada mas nunca confirmada no backend (ex.: app fechado logo
/// após a compra, queda de rede) não seja perdida. O backend é
/// idempotente por apple_transaction_id, então reenviar a mesma
/// transação nunca credita duas vezes.
@MainActor
final class AICreditsTransactionObserver {
    static let shared = AICreditsTransactionObserver()

    private let purchaseService: PurchaseServiceProtocol
    private let creditsService: AICreditsServiceProtocol

    private var updatesTask: Task<Void, Never>?

    // Não-privado para permitir instâncias isoladas em testes — só
    // start() é perigoso de chamar em mais de uma instância ao mesmo
    // tempo (abriria dois listeners de StoreKit.Transaction.updates,
    // duplicando chamadas de rede por transação), então o guard contra
    // uso duplicado fica lá, não no init em si.
    init(
        purchaseService: PurchaseServiceProtocol = PurchaseService(),
        creditsService: AICreditsServiceProtocol = AICreditsService()
    ) {
        self.purchaseService = purchaseService
        self.creditsService = creditsService
    }

    func start() {
        guard updatesTask == nil else { return }

        updatesTask = purchaseService.observeTransactionUpdates {
            [weak self] transaction in
            await self?.reconcile(transaction)
        }

        Task { [weak self] in
            guard let self else { return }

            for transaction in await purchaseService.unfinishedTransactions() {
                await reconcile(transaction)
            }
        }
    }

    private func reconcile(
        _ verified: VerifiedTransaction
    ) async {
        do {
            _ = try await creditsService.registerApplePurchase(
                signedTransaction: verified.jwsRepresentation,
                productID: verified.productID
            )

            await verified.finish()

        } catch {
            // Não finaliza a transação de propósito: será
            // reconciliada de novo no próximo launch ou no próximo
            // evento de Transaction.updates.
        }
    }
}
