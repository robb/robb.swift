// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "robb.swift",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "robb.swift", targets: ["robb.swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/robb/Future.git", .branch("master")),
        .package(url: "https://github.com/robb/HTML-DSL.git", .branch("master")),
        .package(url: "https://github.com/robb/URLRequest-AWS.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-cmark.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "robb.swift",
            dependencies: [ "cmark", "Future", "HTML", "URLRequest+AWS" ])
    ]
)
