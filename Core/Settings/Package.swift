// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Settings",
            targets: ["Settings"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenCombine/OpenCombine.git", revision: "0.14.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Settings",
            dependencies: [
                "OpenCombine"
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings"
            ]
        ),
    ]
)
