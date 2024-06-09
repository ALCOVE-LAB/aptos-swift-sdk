import Foundation
import Types
import BCS

public enum PrivateKeyError: Error {
    case invalidLength
    // Invalid derivation path ${path}
    case invalidDerivationPath(_ path: String)
    // Invalid BIP44 path ${path}
    case invalidBIP44Path(_ path: String)
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
        default:
            return false
        }
    }

}

public protocol PrivateKey: Serializable, Deserializable {
    init(_ hexInput: HexInput) throws
    func sign(message: HexInput) throws -> Signature
    func toUInt8Array() -> [UInt8]
    func publicKey() throws -> any PublicKey
}

extension PrivateKey {
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