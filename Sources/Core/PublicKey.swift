import BCS
import Types

public enum PublicKeyError: Error {
    case invalidLength
}

public protocol PublicKey: Serializable, Deserializable {
    init(_ hexInput: HexInput) throws
    func verifySignature(message: HexInput, signature: Signature) throws -> Bool
    func toUInt8Array() -> [UInt8]
}

extension PublicKey {
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