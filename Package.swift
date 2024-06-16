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
        .library(name: "Aptos", targets: ["Aptos"]),
        .library(name: "BIP32", targets: ["BIP32"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", "1.0.0" ..< "2.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.1.0"),
        .package(url: "https://github.com/Electric-Coin-Company/MnemonicSwift.git", from: "2.2.4"),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.17.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.2")
    ],
    targets: [
        // MARK: - Targets
        .target(
            name: "Aptos",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "CryptoSwift", package: "cryptoswift"),
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
                "BCS",
                "Clients"
            ]
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "MnemonicSwift", package: "MnemonicSwift"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "CryptoSwift", package: "cryptoswift"),
                "Types",
                "BCS",
                "BIP32"
            ]
        ),
        .target(
            name: "BIP32",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]
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
            name: "UnitTests",
            dependencies: [
                "Core",
                "BCS",
                "Types",
            ]
        ),
        .testTarget(
            name: "ClientTests",
            dependencies: [
                "Clients",
            ]
        ),
        .testTarget(
            name: "E2ETests",
            dependencies: [
                "Aptos",
                "Types",
                "Clients"
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
