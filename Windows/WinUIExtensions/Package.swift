// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "WinUIExtensions",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WinUIExtensions",
            targets: [
                "WinUIExtensions",
                "WinUIExtensionsMacros"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", revision: "600.0.0-prerelease-2024-07-24"),
        .package(url: "https://github.com/thebrowsercompany/swift-windowsappsdk", branch: "main"),
        .package(url: "https://github.com/thebrowsercompany/swift-windowsfoundation", branch: "main"),
        .package(url: "https://github.com/fbarbat/swift-winui", revision: "899b33a45beb86d8b7e4145aaf3ef70b865d9fe9"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WinUIExtensions",
            dependencies: [
                .product(name: "WinUI", package: "swift-winui"),
                "WinUIExtensionsMacros"
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "/SUBSYSTEM:WINDOWS"], .when(configuration: .release)),
            ]
        ),
        .target(
            name: "WinUIExtensionsMacros",
            dependencies: [
                .product(name: "WinUI", package: "swift-winui"),
                .product(name: "WinAppSDK", package: "swift-windowsappsdk"),
                .product(name: "WindowsFoundation", package: "swift-windowsfoundation"),
                "WinUIExtensionsMacrosImplementations"
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "/SUBSYSTEM:WINDOWS"], .when(configuration: .release)),
            ]
        ),
        .macro(
            name: "WinUIExtensionsMacrosImplementations",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        // TODO: Macro Tests don't work on Windows
        // .testTarget(
        //     name: "WinUIExtensionsTests",
        //     dependencies: [
        //         "WinUIExtensions",
        //         "WinUIExtensionsMacrosImplementations",
        //         .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        //     ]
        // ),
    ]
)
