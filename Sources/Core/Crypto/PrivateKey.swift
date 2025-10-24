import Foundation
import Types
import BCS

public enum PrivateKeyError: Error {
    case invalidLength
    // Invalid derivation path ${path}
    case invalidDerivationPath(_ path: String)
    // Invalid BIP44 path ${path}
    case invalidBIP44Path(_ path: String)
    // Invalid AIP-80 format
    case invalidAIP80Format(String)
}

/// Variants of private keys that can comply with the AIP-80 standard.
/// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
public enum PrivateKeyVariant: String, Sendable {
    case ed25519 = "ed25519"
    case secp256k1 = "secp256k1"
    case secp256r1 = "secp256r1"
}

extension PrivateKeyError: Equatable {
    public static func == (lhs: PrivateKeyError, rhs: PrivateKeyError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidLength, .invalidLength):
            return true
        case (.invalidDerivationPath(let path1), .invalidDerivationPath(let path2)):
            return path1 == path2
        case (.invalidBIP44Path(let path1), .invalidBIP44Path(let path2)):
            return path1 == path2
        case (.invalidAIP80Format(let msg1), .invalidAIP80Format(let msg2)):
            return msg1 == msg2
        default:
            return false
        }
    }

}

/// AIP-80 compliant private key utilities.
/// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
public struct AIP80PrivateKey {
    /// The AIP-80 compliant prefixes for each private key type. Append this to a private key's hex representation
    /// to get an AIP-80 compliant string.
    ///
    /// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
    public static let prefixes: [PrivateKeyVariant: String] = [
        .ed25519: "ed25519-priv-",
        .secp256k1: "secp256k1-priv-",
        .secp256r1: "secp256r1-priv-"
    ]

    /// Format a HexInput to an AIP-80 compliant string.
    ///
    /// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
    ///
    /// - Parameters:
    ///   - privateKey: The HexString or [UInt8] format of the private key.
    ///   - type: The private key type
    /// - Returns: An AIP-80 compliant string representation
    public static func formatPrivateKey(_ privateKey: HexInput, type: PrivateKeyVariant) throws -> String {
        guard let prefix = prefixes[type] else {
            throw PrivateKeyError.invalidAIP80Format("Unknown private key type: \(type)")
        }

        // Remove the prefix if it exists
        var formattedPrivateKey = privateKey
        if let strKey = formattedPrivateKey as? String, strKey.hasPrefix(prefix) {
            // Extract the hex part after the prefix (split by "-" and get the last part)
            let components = strKey.components(separatedBy: "-")
            if components.count >= 3 {
                formattedPrivateKey = components[2]
            }
        }

        let hex = try Hex.fromHexInput(formattedPrivateKey)
        return "\(prefix)\(hex.toStringWithoutPrefix())"
    }

    /// Parse a HexInput that may be a HexString, [UInt8], or an AIP-80 compliant string to a Hex instance.
    ///
    /// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
    ///
    /// - Parameters:
    ///   - value: A HexString, [UInt8], or an AIP-80 compliant string.
    ///   - type: The private key type
    ///   - strict: If true, the value MUST be compliant with AIP-80. If false, non-compliant formats are allowed without warning. If nil (default), non-compliant formats are allowed but a warning is printed.
    /// - Returns: A Hex instance containing the private key bytes
    public static func parseHexInput(_ value: HexInput, type: PrivateKeyVariant, strict: Bool? = nil) throws -> Hex {
        guard let prefix = prefixes[type] else {
            throw PrivateKeyError.invalidAIP80Format("Unknown private key type: \(type)")
        }

        if let strValue = value as? String {
            if strict == true && !strValue.hasPrefix(prefix) {
                // The value does not start with the AIP-80 prefix, and strict is true.
                throw PrivateKeyError.invalidAIP80Format("Invalid HexString input while parsing private key. Must be AIP-80 compliant string.")
            }

            if strValue.hasPrefix(prefix) {
                // AIP-80 Compliant String input
                let components = strValue.components(separatedBy: "-")
                if components.count >= 3 {
                    return try Hex.fromHexString(components[2])
                } else {
                    throw PrivateKeyError.invalidAIP80Format("Invalid AIP-80 format")
                }
            } else {
                // HexString input (not AIP-80 compliant)
                // If strict is not explicitly false, show a warning
                if strict != false {
                    print("[Aptos SDK] It is recommended that private keys are AIP-80 compliant (https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md). You can fix the private key by formatting it with `AIP80PrivateKey.formatPrivateKey(privateKey: HexInput, type: PrivateKeyVariant)`.")
                }
                return try Hex.fromHexInput(strValue)
            }
        } else {
            // The value is a [UInt8] or Data
            return try Hex.fromHexInput(value)
        }
    }
}

public protocol PrivateKey: Serializable, Deserializable, Equatable, Hashable, Sendable {
    init(_ hexInput: HexInput) throws
    func sign(message: HexInput) throws -> any Signature
    func toUInt8Array() -> [UInt8]
    func toString() -> String
    func publicKey() throws -> any PublicKey
}

extension PrivateKey {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toUInt8Array())
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toUInt8Array() == rhs.toUInt8Array()
    }
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }
    static func deserialize(from deserializer: Deserializer) throws -> Self {
        let bytes = try deserializer.deserializeBytes()
        return try Self(bytes)
    }

    public static func deserialize(deserializer: Deserializer) throws -> Self {
        let bytes = try deserializer.deserializeBytes()
        return try Self(bytes)
    }
}