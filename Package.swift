// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "robb.swift",
    platforms: [
        .macOS(.v10_13)
    ],
    dependencies: [
        .package(url: "https://github.com/robb/HTML-DSL.git", .branch("master")),
        .package(url: "https://github.com/aasimk2000/Down.git", .branch("spm")),
        .package(url: "https://github.com/mxcl/Path.swift.git", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "robb.swift",
            dependencies: [ "Down", "HTML", "Path" ])
    ]
)
