// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "robb.swift",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "main", targets: ["main"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-cmark.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/robb/Future.git", .branch("master")),
        .package(url: "https://github.com/robb/Swim.git", .branch("main")),
        .package(url: "https://github.com/robb/URLRequest-AWS.git", .branch("master")),
    ],
    targets: [
        .executableTarget(
            name: "main",
            dependencies: [
                "robb.swift",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "robb.swift",
            dependencies: [
                .product(name: "cmark", package: "swift-cmark"),
                "Future",
                .product(name: "HTML", package: "Swim"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "URLRequest+AWS", package: "URLRequest-AWS")
            ]),
    ]
)
