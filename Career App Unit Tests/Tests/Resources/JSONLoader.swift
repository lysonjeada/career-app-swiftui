//
//  JSONLoader.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

import Foundation

enum JSONLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) throws -> T {
        let bundle = Bundle(for: HomeViewModelTests.self) // ou outro teste seu
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("❌ Could not find \(filename).json in test bundle")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
