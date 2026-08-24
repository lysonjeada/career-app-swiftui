//
//  AICreditsView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import SwiftUI
#if DEBUG
import StoreKit
#endif

struct AICreditsView: View {
    @StateObject private var viewModel = AICreditsViewModel()

    init() {}

    #if DEBUG
    init(viewModel: AICreditsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    #endif

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()

            case .loaded:
                content

            case .noProductsAvailable:
                ContentUnavailableView {
                    Label(
                        "Nenhum pacote disponível",
                        systemImage: "cart.badge.questionmark"
                    )
                } description: {
                    Text(
                        "No momento não há pacotes de créditos disponíveis para compra."
                    )
                }

            case let .error(message):
                ContentUnavailableView {
                    Label(
                        "Não foi possível carregar",
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(message)
                } actions: {
                    Button("Tentar novamente") {
                        viewModel.load()
                    }
                }
            }
        }
        .navigationTitle("Créditos de IA")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load()
        }
        .overlay(alignment: .bottom) {
            if let snackbar = snackbarContent {
                SnackbarView(
                    message: snackbar.message,
                    type: snackbar.type
                )
                .padding(.bottom, 24)
                .padding(.horizontal)
            }
        }
        .animation(.default, value: viewModel.purchaseState)
        .onChange(of: viewModel.purchaseState) { _, newValue in
            handlePurchaseStateChange(newValue)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 28) {
                balanceSection

                Text(
                    "Use seus créditos para gerar perguntas, simular entrevistas, criar planos de estudo e utilizar outras ferramentas de IA."
                )
                .font(.footnote)
                .foregroundColor(.descriptionGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Comprar mais créditos")
                        .font(.headline)
                        .foregroundColor(.persianBlue)

                    ForEach(viewModel.packages) { package in
                        creditPackageCard(package)
                    }
                }
            }
            .padding()
        }
        .background(Color.backgroundLightGray)
    }

    private var balanceSection: some View {
        VStack(spacing: 8) {
            Text("Requests disponíveis")
                .font(.subheadline)
                .foregroundColor(.descriptionGray)

            Text("\(viewModel.balance)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.persianBlue)
                .contentTransition(.numericText())
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(viewModel.balance) requests disponíveis"
        )
    }

    @ViewBuilder
    private func creditPackageCard(
        _ package: AICreditPackageDisplay
    ) -> some View {
        let isPurchasingThis = isPurchasing(package)
        let isAnyPurchaseInFlight = isAnyPurchaseInFlight

        Card {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(package.credits) requests")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.persianBlue)

                    Text(package.priceText)
                        .font(.subheadline)
                        .foregroundColor(.descriptionGray)
                }

                Spacer()

                Button {
                    viewModel.purchase(productID: package.id)
                } label: {
                    Group {
                        if isPurchasingThis {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Comprar")
                        }
                    }
                    .frame(width: 90)
                    .padding(.vertical, 10)
                    .background(Color.persianBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isAnyPurchaseInFlight)
                .opacity(
                    isAnyPurchaseInFlight && !isPurchasingThis
                        ? 0.5
                        : 1
                )
            }
            .padding()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(package.credits) requests por \(package.priceText)"
        )
        .accessibilityAddTraits(.isButton)
    }

    private func isPurchasing(
        _ package: AICreditPackageDisplay
    ) -> Bool {
        if case let .purchasing(product) = viewModel.purchaseState {
            return product.rawValue == package.id
        }

        return false
    }

    private var isAnyPurchaseInFlight: Bool {
        if case .purchasing = viewModel.purchaseState {
            return true
        }

        return false
    }

    private var snackbarContent: (message: String, type: SnackbarType)? {
        switch viewModel.purchaseState {
        case let .success(creditsAdded):
            return (
                "\(creditsAdded) créditos adicionados! Saldo: \(viewModel.balance)",
                .success
            )

        case .pending:
            return (
                "Compra em análise. Você será avisado quando for aprovada.",
                .info
            )

        case let .error(message):
            return (message, .error)

        // Cancelamento não precisa de alerta — o usuário já sabe que
        // cancelou a compra na folha da Apple.
        case .idle, .purchasing, .cancelled:
            return nil
        }
    }

    private func handlePurchaseStateChange(
        _ newValue: AICreditsViewModel.PurchaseState
    ) {
        switch newValue {
        case .success, .cancelled, .pending, .error:
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                viewModel.resetPurchaseState()
            }

        case .idle, .purchasing:
            break
        }
    }
}

#if DEBUG
#Preview("Com saldo e pacotes") {
    NavigationStack {
        AICreditsView(
            viewModel: .preview(
                balance: 18,
                packages: [
                    AICreditPackageDisplay(
                        id: AICreditProduct.ten.rawValue,
                        credits: 10,
                        priceText: "R$ 4,90"
                    ),
                    AICreditPackageDisplay(
                        id: AICreditProduct.thirty.rawValue,
                        credits: 30,
                        priceText: "R$ 12,90"
                    ),
                    AICreditPackageDisplay(
                        id: AICreditProduct.hundred.rawValue,
                        credits: 100,
                        priceText: "R$ 34,90"
                    ),
                ]
            )
        )
    }
}

#Preview("Sem produtos disponíveis") {
    NavigationStack {
        AICreditsView(
            viewModel: .preview(state: .noProductsAvailable)
        )
    }
}

#Preview("Erro ao carregar") {
    NavigationStack {
        AICreditsView(
            viewModel: .preview(
                state: .error("Não foi possível conectar ao servidor.")
            )
        )
    }
}

private extension AICreditsViewModel {
    /// Só para Preview: preenche o estado diretamente, sem depender de
    /// backend, StoreKit real ou AuthSession — `Product` não tem
    /// inicializador público, então a View sempre trabalha com
    /// `AICreditPackageDisplay`, que é possível mockar livremente.
    static func preview(
        balance: Int = 0,
        packages: [AICreditPackageDisplay] = [],
        state: AICreditsViewModel.State = .loaded
    ) -> AICreditsViewModel {
        final class NeverLoadingCreditsService: AICreditsServiceProtocol {
            func fetchBalance() async throws -> Int { 0 }
            func registerApplePurchase(
                signedTransaction: String,
                productID: String
            ) async throws -> AICreditPurchaseResult {
                AICreditPurchaseResult(
                    creditsAdded: 0,
                    balance: 0,
                    alreadyProcessed: false
                )
            }
        }

        final class NeverLoadingPurchaseService: PurchaseServiceProtocol {
            func fetchProducts() async throws -> [Product] { [] }
            func purchase(productID: String) async throws -> PurchaseResult {
                .userCancelled
            }
            func observeTransactionUpdates(
                onUpdate: @escaping (VerifiedTransaction) async -> Void
            ) -> Task<Void, Never> {
                Task {}
            }
            func unfinishedTransactions() async -> [VerifiedTransaction] {
                []
            }
        }

        let viewModel = AICreditsViewModel(
            creditsService: NeverLoadingCreditsService(),
            purchaseService: NeverLoadingPurchaseService()
        )

        viewModel.applyPreviewState(
            balance: balance,
            packages: packages,
            state: state
        )

        return viewModel
    }
}
#endif
