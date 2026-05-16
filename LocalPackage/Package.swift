// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocalPackage",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "LocalPackage",
            targets: ["LocalPackage", "KeychainService"]
        ),
        .executable(
            name: "Main",
            targets: ["Main"]
        )
    ],
    targets: [
        .target(
            name: "LocalPackage",
            path: "Sources/LocalPackage"),
        .target(
            name: "KeychainService",
            path: "Sources/KeychainService"),
        .executableTarget(
            name: "Main",
            dependencies: ["LocalPackage"],
            path: "Sources/Main"
        ),
    ]
)
