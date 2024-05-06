// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "aptos-sdk",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "Aptos", targets: ["Aptos"])
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0")
    ],
    targets: [
        // MARK: - Targets
        .target(
            name: "Aptos",
            dependencies: [
                .product(name: "BigInt", package: "BigInt")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AptosTests",
            dependencies: ["Aptos"],
            path: "Tests"
        )
    ]
)
