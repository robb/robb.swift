// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "robb.swift",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "main", targets: ["main"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-cmark.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/robb/Future.git", .branch("master")),
        .package(url: "https://github.com/robb/Swim.git", .branch("main")),
        .package(url: "https://github.com/robb/URLRequest-AWS.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "main",
            dependencies: [ "robb.swift", "ArgumentParser" ]),
        .target(
            name: "robb.swift",
            dependencies: [ "cmark", "Future", "HTML", "Logging", "URLRequest+AWS" ]),
    ]
)
