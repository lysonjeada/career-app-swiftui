//
//  CareerAPI.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/06/25.
//

import Foundation

enum StylishStoreAPI {
    case postQuestion
    case getQuestions
    case getCategories
    case getSales
    case getProducts
    case getWishlist
    case getCart
}

extension StylishStoreAPI {
    var baseURL: String {
        CareerURL.lysAPI.rawValue
    }

    var path: String {
        switch self {
        case .getQuestions, .postQuestion:
            return "/questions"
        case .getCategories:
            return "/categories"
        case .getSales:
            return "/hasSale"
        case .getProducts:
            return "/products"
        case .getWishlist:
            return "/wishlist/8765273"
        case .getCart:
            return "/cart/8765273"
            
        }
    }

    var method: HTTPMethod {
        switch self {
        case .postQuestion:
            return .post
        default:
            return .get
        }
    }

    var body: Data? {
        switch self {
        case .postQuestion:
            return nil
//            return try? JSONEncoder().encode(question)
        default:
            return nil
        }
    }

    var urlRequest: URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}
