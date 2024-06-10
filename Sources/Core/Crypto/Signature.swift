import Foundation
import Types
import BCS


public enum SignatureError: Error {
    case invalidLength
}

public protocol Signature: Serializable, Deserializable, Equatable, Hashable, Sendable {
    func toUInt8Array() -> [UInt8]
    init(_ hexInput: HexInput) throws 
}


public extension Signature {
    func hash(into hasher: inout Hasher) {
        hasher.combine(toUInt8Array())
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.toUInt8Array() == rhs.toUInt8Array()
    }
    func toString() -> String {
        return try! Hex.fromHexInput(toUInt8Array()).toString()
    }
}

extension Signature {
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }
    
    public static func deserialize(deserializer: Deserializer) throws -> Self {
        let bytes = try deserializer.deserializeBytes()
        return try Self(bytes)
    }
}