// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "career-app-swiftui",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependências do projeto
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.12.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "600.0.0")),
        .package(url: "https://github.com/apple/swift-testing.git", branch: "main") // Como você tem uma dependência de branch
    ],
    targets: [
        // Target do app principal
        .target(
            name: "career-app-swiftui",
            dependencies: [],
            path: "Sources",
            exclude: ["main.swift"] // Exclua arquivos não necessários
        ),
        .testTarget(
            name: "CareerAppUnitTests",
            dependencies: [
                "career-app-swiftui",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Testing", package: "swift-testing"),
            ],
             path: "Career App Unit Tests/Tests",
            exclude: ["main.swift"] // Evita duplicidade
        ),
    ]
)