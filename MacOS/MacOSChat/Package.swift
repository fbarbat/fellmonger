// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacOSChat",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MacOSChat",
            targets: ["MacOSChat"]),
    ],
    dependencies: [
        .package(path: "../MacOSSwiftExtensions"),
        .package(path: "../../Core/Chat"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", exact: "2.3.1"),
        .package(url: "https://github.com/JohnSundell/Splash", exact: "0.16.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MacOSChat",
            dependencies: [
                "MacOSSwiftExtensions",
                "Chat",
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                "Splash"
            ]
        ),
        .testTarget(
            name: "MacOSChatTests",
            dependencies: ["MacOSChat"]
        ),
    ]
)
