// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "fellmonger-windows",
    products: [
        .executable(name: "Fellmonger", targets: ["Fellmonger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/thebrowsercompany/swift-windowsappsdk", branch: "main"),
        .package(url: "https://github.com/thebrowsercompany/swift-windowsfoundation", branch: "main"),
        .package(url: "https://github.com/fbarbat/swift-winui", revision: "899b33a45beb86d8b7e4145aaf3ef70b865d9fe9"),
        .package(path: "../../Core/Settings"),
        .package(path: "../../Core/Chat"),
        .package(path: "../WinUIExtensions")
    ],
    targets: [
        .executableTarget(
            name: "Fellmonger",
            dependencies: [
                .product(name: "WinUI", package: "swift-winui"),
                .product(name: "WinAppSDK", package: "swift-windowsappsdk"),
                .product(name: "WindowsFoundation", package: "swift-windowsfoundation"),
                "Settings",
                "Chat",
                "WinUIExtensions"
            ],
            path:"Sources",
            resources: [.process("Resources")],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "/SUBSYSTEM:WINDOWS"], .when(configuration: .release)),
                // Update the entry point to point to the generated swift function, this lets us keep the same main method
                // for debug/release
                .unsafeFlags(["-Xlinker", "/ENTRY:mainCRTStartup"], .when(configuration: .release)),
            ]
        ),
    ]
)
