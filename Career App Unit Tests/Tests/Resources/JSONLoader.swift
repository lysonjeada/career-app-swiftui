//
//  JSONLoader.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

import Foundation
import Testing
// No import Testing needed for JSONLoader itself

// --- IMPORTANT: Place this dummy class in your Test Target ---
// You can put this directly in your HomeViewModelTests.swift file,
// or in a separate file within your test target (e.g., TestHelpers.swift).
private class TestBundleMarker {} // This is a simple class to get a reference to the test bundle

// --- Your JSONLoader ---
enum JSONLoader {
    static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) throws -> T {
        // Use the dummy class to get the bundle for the current test target
        let testBundle = Bundle(for: TestBundleMarker.self)

        guard let url = testBundle.url(forResource: filename, withExtension: "json") else {
            // Provide a more informative error message if the file isn't found
            fatalError("❌ Could not find \(filename).json in test bundle. " +
                       "Make sure it's added to your test target's 'Copy Bundle Resources'. " +
                       "Bundle path: \(testBundle.bundleURL)")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        // If you are using the custom `init(from:)` in your `InterviewResponse` model
        // to handle the mixed date formats, no special `dateDecodingStrategy` is needed here.
        // If you opted for a global date decoding strategy, apply it here.

        return try decoder.decode(T.self, from: data)
    }
}

func awaitCondition(
    until condition: @autoclosure @escaping () -> Bool,
    timeout: TimeInterval = 1.0,
    interval: TimeInterval = 0.01
    // Remove 'message' parameter, or change its type if you want to pass a custom one
    // directly to #expect, but for simplicity, let's rely on #expect's default reporting.
    // file: StaticString = #filePath, // No longer needed here
    // line: UInt = #line // No longer needed here
) async throws {
    let startTime = Date()
    while !condition() && Date().timeIntervalSince(startTime) < timeout {
        await Task.yield()
        try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
    }
    
    // Correct usage of #expect:
    // It captures file and line automatically.
    // For a simple condition check, you can just pass the condition.
    // If you want a custom message, you'd use #expect(condition(), "Your custom message")
    // but the error you got indicates it expects a Comment type.
    // Let's go with the simplest, most common usage first.
    #expect(condition())
    
    // If you *really* want a custom message string, you'd have to wrap it in a Comment:
    // #expect(condition(), Comment(message)) // If you re-add 'message: String' to function signature
    // However, for basic true/false checks, #expect(condition()) is often enough,
    // and the test report will show which #expect failed.
}
