//
//  APIService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import Foundation

protocol APIServiceProtocol {
    func request<T: Decodable>(_ endpoint: TechStepAPI, as type: T.Type) async throws -> T
}

final class APIService: APIServiceProtocol {

    func request<T: Decodable>(_ endpoint: TechStepAPI, as type: T.Type) async throws -> T {
        let request = endpoint.urlRequest

        // 📤 Log da Request
        print("➡️ [REQUEST]")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 📥 Log da Response
            if let httpResponse = response as? HTTPURLResponse {
                print("⬅️ [RESPONSE]")
                print("Status Code: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Body: \(responseString)")
            }

            // ✅ Status Code Check
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw URLError(.badServerResponse)
            }

            // ✅ Decoding
            let decoded = try JSONDecoder().decode(T.self, from: data)
            print("✅ Decoding succeeded for type: \(T.self)")
            return decoded

        } catch {
            print("🛑 Error during request for endpoint: \(endpoint.path)")
            print(error.localizedDescription)
            throw error
        }
    }
}
