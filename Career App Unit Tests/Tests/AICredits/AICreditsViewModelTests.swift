//
//  AICreditsViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app
import Foundation

@Suite
struct AICreditsViewModelTests {

    // MARK: - load()

    @Test @MainActor
    func testLoad_WhenNoProductsAreAvailable_SetsNoProductsAvailableStateButStillLoadsBalance() async throws {
        // Arrange: `Product` não tem inicializador público, então não é
        // possível popular `productsToReturn` com pacotes reais nos
        // testes — este caso cobre o caminho real e testável (lista
        // vazia) e confirma que o saldo ainda é carregado corretamente
        // mesmo sem produtos.
        let creditsService = AICreditsServiceMock(isSuccess: true, balanceToReturn: 18)
        let purchaseService = PurchaseServiceMock()
        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.load()
        try await awaitCondition(until: viewModel.state == .noProductsAvailable, timeout: 5.0)

        // Assert
        #expect(viewModel.state == .noProductsAvailable)
        #expect(viewModel.balance == 18)
        #expect(viewModel.packages.isEmpty)
    }

    @Test @MainActor
    func testLoad_WhenBalanceFetchFails_SetsErrorState() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: false)
        let purchaseService = PurchaseServiceMock()
        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.load()

        func isErrorState() -> Bool {
            if case .error = viewModel.state { return true }
            return false
        }

        try await awaitCondition(until: isErrorState(), timeout: 5.0)

        // Assert
        if case let .error(message) = viewModel.state {
            #expect(!message.isEmpty)
        } else {
            Issue.record("Esperava state .error, mas obteve \(viewModel.state)")
        }
    }

    @Test @MainActor
    func testLoad_WhenProductsFetchFails_SetsErrorState() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true, balanceToReturn: 18)
        let purchaseService = PurchaseServiceMock()
        purchaseService.productsError = URLError(.badServerResponse)
        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.load()

        func isErrorState() -> Bool {
            if case .error = viewModel.state { return true }
            return false
        }

        try await awaitCondition(until: isErrorState(), timeout: 5.0)

        // Assert
        if case .error = viewModel.state {
            // esperado
        } else {
            Issue.record("Esperava state .error, mas obteve \(viewModel.state)")
        }
    }

    // MARK: - purchase(productID:)

    @Test @MainActor
    func testPurchase_WithUnknownProductID_SetsErrorWithoutCallingPurchaseService() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true)
        let purchaseService = PurchaseServiceMock()
        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: "not.a.real.product")

        // Assert
        #expect(viewModel.purchaseState == .error("Produto desconhecido."))
        #expect(purchaseService.purchaseCallCount == 0)
    }

    @Test @MainActor
    func testPurchase_Success_UpdatesBalanceAndFinishesTransactionOnlyAfterBackendConfirms() async throws {
        // Arrange
        var finishCallCount = 0
        let verified = VerifiedTransaction.fake(
            productID: AICreditProduct.thirty.rawValue,
            onFinish: { finishCallCount += 1 }
        )

        let creditsService = AICreditsServiceMock(
            isSuccess: true,
            balanceToReturn: 18,
            purchaseResultToReturn: AICreditPurchaseResult(
                creditsAdded: 30,
                balance: 48,
                alreadyProcessed: false
            )
        )
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseResultToReturn = .success(verified)

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: AICreditProduct.thirty.rawValue)

        try await awaitCondition(
            until: viewModel.purchaseState == .success(creditsAdded: 30),
            timeout: 5.0
        )

        // Assert
        #expect(viewModel.purchaseState == .success(creditsAdded: 30))
        #expect(viewModel.balance == 48)
        #expect(finishCallCount == 1)
        #expect(purchaseService.receivedPurchaseProductID == AICreditProduct.thirty.rawValue)
        #expect(creditsService.receivedProductID == AICreditProduct.thirty.rawValue)
        #expect(creditsService.receivedSignedTransaction == "fake-jws")
    }

    @Test @MainActor
    func testPurchase_WhenUserCancels_SetsCancelledStateWithoutCallingBackend() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true)
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseResultToReturn = .userCancelled

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: AICreditProduct.ten.rawValue)
        try await awaitCondition(until: viewModel.purchaseState == .cancelled, timeout: 5.0)

        // Assert
        #expect(viewModel.purchaseState == .cancelled)
        #expect(creditsService.receivedSignedTransaction == nil)
    }

    @Test @MainActor
    func testPurchase_WhenPending_SetsPendingStateWithoutCallingBackend() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true)
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseResultToReturn = .pending

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: AICreditProduct.ten.rawValue)
        try await awaitCondition(until: viewModel.purchaseState == .pending, timeout: 5.0)

        // Assert
        #expect(viewModel.purchaseState == .pending)
        #expect(creditsService.receivedSignedTransaction == nil)
    }

    @Test @MainActor
    func testPurchase_WhenStoreKitPurchaseFails_SetsErrorState() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true)
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseError = PurchaseServiceError.verificationFailed

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: AICreditProduct.ten.rawValue)

        func isErrorState() -> Bool {
            if case .error = viewModel.purchaseState { return true }
            return false
        }

        try await awaitCondition(until: isErrorState(), timeout: 5.0)

        // Assert
        if case .error = viewModel.purchaseState {
            // esperado
        } else {
            Issue.record("Esperava purchaseState .error, mas obteve \(viewModel.purchaseState)")
        }
    }

    @Test @MainActor
    func testPurchase_WhenBackendRejectsPurchase_SetsErrorStateAndNeverFinishesTransaction() async throws {
        // Arrange: a Apple aprovou a compra, mas o backend rejeitou o
        // registro (ex.: transação inválida) — a transação NUNCA deve
        // ser finalizada nesse caso, para não perder a compra.
        var finishCallCount = 0
        let verified = VerifiedTransaction.fake(
            onFinish: { finishCallCount += 1 }
        )

        let creditsService = AICreditsServiceMock(isSuccess: false)
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseResultToReturn = .success(verified)

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )

        // Act
        viewModel.purchase(productID: AICreditProduct.ten.rawValue)

        func isErrorState() -> Bool {
            if case .error = viewModel.purchaseState { return true }
            return false
        }

        try await awaitCondition(until: isErrorState(), timeout: 5.0)

        // Assert
        #expect(finishCallCount == 0)
    }

    @Test @MainActor
    func testResetPurchaseState_SetsPurchaseStateBackToIdle() async throws {
        // Arrange
        let creditsService = AICreditsServiceMock(isSuccess: true)
        let purchaseService = PurchaseServiceMock()
        purchaseService.purchaseResultToReturn = .userCancelled

        let viewModel = AICreditsViewModel(
            creditsService: creditsService,
            purchaseService: purchaseService
        )
        viewModel.purchase(productID: AICreditProduct.ten.rawValue)
        try await awaitCondition(until: viewModel.purchaseState == .cancelled, timeout: 5.0)

        // Act
        viewModel.resetPurchaseState()

        // Assert
        #expect(viewModel.purchaseState == .idle)
    }
}
