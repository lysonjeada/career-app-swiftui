//
//  AICreditProduct.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/08/26.
//

import Foundation

/// Fonte central dos Product IDs de créditos de IA (consumíveis,
/// StoreKit 2). Os mesmos valores existem no backend, em
/// app/credits/config.py::AI_CREDIT_PRODUCTS — não há como
/// compartilhar código entre Swift e Python, então qualquer mudança
/// aqui precisa ser replicada lá também.
enum AICreditProduct: String, CaseIterable, Identifiable {
    case ten = "lys.com.career-app.credits.10"
    case thirty = "lys.com.career-app.credits.30"
    case hundred = "lys.com.career-app.credits.100"

    var id: String { rawValue }

    var credits: Int {
        switch self {
        case .ten:
            return 10
        case .thirty:
            return 30
        case .hundred:
            return 100
        }
    }

    static var allProductIDs: [String] {
        allCases.map(\.rawValue)
    }
}
