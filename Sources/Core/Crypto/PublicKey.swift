import BCS
import Types

public enum PublicKeyError: Error {
    case invalidLength
}

public protocol PublicKey: Serializable, Deserializable, Equatable, Hashable, Sendable {
    init(_ hexInput: HexInput) throws
    func verifySignature(message: HexInput, signature: any Signature) throws -> Bool
    func toUInt8Array() -> [UInt8]
}

extension PublicKey {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toUInt8Array())
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toUInt8Array() == rhs.toUInt8Array()
    }
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }
    public static func deserialize(deserializer: Deserializer) throws -> Self {
        return try Self.init(deserializer.deserializeBytes())
    }
}

public extension PublicKey {
    func toString() -> String {
        return try! Hex.fromHexInput(toUInt8Array()).toString()
    }
}

public protocol AccountPublicKey: PublicKey {
   func authKey() throws -> AuthenticationKey
}