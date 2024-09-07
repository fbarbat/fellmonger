// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chat",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Chat",
            targets: ["Chat"]
        ),
    ],
    dependencies: [
        .package(path: "../SwiftExtensions"),
        .package(path: "../Settings"),
        .package(url: "https://github.com/fbarbat/OllamaKit", revision: "6b67b3f8024cba2dc9c6597b6dcbf1e6d86a5822"),
        .package(url: "https://github.com/MacPaw/OpenAI", exact: "0.2.9"),
        .package(url: "https://github.com/fbarbat/SwiftAnthropic", revision: "b2544eb4c0513967df9162948ad9ad311b2cca2b"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Chat",
            dependencies: [
                "SwiftExtensions",
                "Settings",
                "OllamaKit",
                "SwiftAnthropic",
                "OpenAI",
            ]
        ),
        .testTarget(
            name: "ChatTests",
            dependencies: ["Chat"]
        ),
    ]
)
