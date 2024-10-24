// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "career-app",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v14)
    ],
    dependencies: [
        // Dependência do swift-snapshot-testing
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.12.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "career-appUITests",
            dependencies: [
                // Adiciona a dependência do snapshot testing ao target
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
    ]
)

