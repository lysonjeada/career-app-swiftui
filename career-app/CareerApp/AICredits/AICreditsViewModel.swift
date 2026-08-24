//
//  AICreditsViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import Foundation
import StoreKit

@MainActor
final class AICreditsViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case loading
        case loaded
        case noProductsAvailable
        case error(String)
    }

    enum PurchaseState: Equatable {
        case idle
        case purchasing(AICreditProduct)
        case success(creditsAdded: Int)
        case cancelled
        case pending
        case error(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var purchaseState: PurchaseState = .idle
    @Published private(set) var balance: Int = 0
    @Published private(set) var packages: [AICreditPackageDisplay] = []

    private let creditsService: AICreditsServiceProtocol
    private let purchaseService: PurchaseServiceProtocol

    private var loadTask: Task<Void, Never>?
    private var purchaseTask: Task<Void, Never>?

    init(
        creditsService: AICreditsServiceProtocol = AICreditsService(),
        purchaseService: PurchaseServiceProtocol = PurchaseService()
    ) {
        self.creditsService = creditsService
        self.purchaseService = purchaseService
    }

    func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task { [weak self] in
            guard let self else { return }

            async let balanceResult = creditsService.fetchBalance()
            async let productsResult = purchaseService.fetchProducts()

            do {
                let (fetchedBalance, fetchedProducts) = try await (
                    balanceResult, productsResult
                )

                guard !Task.isCancelled else { return }

                balance = fetchedBalance
                packages = Self.sortedByCredits(
                    fetchedProducts.compactMap {
                        AICreditPackageDisplay(product: $0)
                    }
                )

                state = packages.isEmpty
                    ? .noProductsAvailable
                    : .loaded

            } catch {
                guard !Task.isCancelled else { return }
                state = .error(error.localizedDescription)
            }
        }
    }

    func purchase(productID: String) {
        guard let creditProduct = AICreditProduct(
            rawValue: productID
        ) else {
            purchaseState = .error("Produto desconhecido.")
            return
        }

        // Evita disparar uma segunda compra enquanto uma já está em
        // andamento (o botão correspondente também fica desabilitado
        // na View, isso é só uma segunda barreira).
        if case .purchasing = purchaseState {
            return
        }

        purchaseTask?.cancel()
        purchaseState = .purchasing(creditProduct)

        purchaseTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await purchaseService.purchase(
                    productID: productID
                )

                switch result {
                case let .success(transaction):
                    try await confirmPurchaseWithBackend(
                        transaction: transaction
                    )

                case .pending:
                    purchaseState = .pending

                case .userCancelled:
                    purchaseState = .cancelled
                }

            } catch {
                purchaseState = .error(error.localizedDescription)
            }
        }
    }

    /// Compartilhado com `AICreditsTransactionObserver`, que chama isso
    /// para transações pendentes reconciliadas fora do fluxo de compra
    /// ativo (ex.: no launch do app).
    func confirmPurchaseWithBackend(
        transaction verified: VerifiedTransaction
    ) async throws {
        let result = try await creditsService.registerApplePurchase(
            signedTransaction: verified.jwsRepresentation,
            productID: verified.productID
        )

        // Só finaliza a transação depois que o backend confirmou o
        // registro (de forma idempotente) — nunca antes, para não
        // perder a compra se a chamada ao backend falhar.
        await verified.finish()

        balance = result.balance
        purchaseState = .success(creditsAdded: result.creditsAdded)
    }

    func resetPurchaseState() {
        purchaseState = .idle
    }

    private static func sortedByCredits(
        _ packages: [AICreditPackageDisplay]
    ) -> [AICreditPackageDisplay] {
        packages.sorted { $0.credits < $1.credits }
    }

    deinit {
        loadTask?.cancel()
        purchaseTask?.cancel()
    }
}

#if DEBUG
extension AICreditsViewModel {
    /// Preenche o estado diretamente — só para uso em `#Preview`.
    /// `Product` não tem inicializador público, então esta é a única
    /// forma de popular `packages` sem depender do StoreKit real
    /// (fica no mesmo arquivo de `AICreditsViewModel` para poder
    /// escrever nas propriedades `private(set)`).
    func applyPreviewState(
        balance: Int,
        packages: [AICreditPackageDisplay],
        state: State
    ) {
        self.balance = balance
        self.packages = packages
        self.state = state
    }
}
#endif

/// Representação de um pacote de créditos pronta para a View exibir —
/// desacoplada de `StoreKit.Product` (que não tem inicializador
/// público, então não dá para criar um fake dele em Previews/testes).
struct AICreditPackageDisplay: Identifiable, Equatable {
    let id: String
    let credits: Int
    let priceText: String

    init(id: String, credits: Int, priceText: String) {
        self.id = id
        self.credits = credits
        self.priceText = priceText
    }

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
