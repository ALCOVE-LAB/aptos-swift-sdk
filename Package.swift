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
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.3.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.1.0")
    ],
    targets: [
        // MARK: - Targets
        .target(
            name: "Aptos",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                "Clients",
                "Utils",
                "Types",
                "Core",
                "BCS"
            ]
        ),
        .target(
            name: "Clients",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ]
        ),
        .target(
            name: "BCS",
            dependencies: [
                .product(name: "BigInt", package: "BigInt")
            ]
        ),
        .target(
            name: "Types",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                "BCS"
            ]
        ),
        .target(
            name: "Core"
        ),
        .target(
            name: "Utils"
        ),
        // MARK: - Examples
        .executableTarget(
            name: "ClientTest",
            dependencies: [
                "Clients",
            ]
        ),
        // MARK: - TestTargets
        .testTarget(
            name: "AptosTests",
            dependencies: [
                "Aptos",
                "BCS",
                "Types",
                "Core",
                "Utils",
                "Clients"
            ],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
