import Foundation
import Types
import BCS


public enum SignatureError: Error {
    case invalidLength
}

public protocol Signature: Serializable {
    func toUInt8Array() -> [UInt8]
    init(_ hexInput: HexInput) throws 
}

public extension Signature {
    func toString() -> String {
        return try! Hex.fromHexInput(toUInt8Array()).toString()
    }
}

extension Signature {
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }
    
    public static func deserialize(from deserializer: Deserializer) throws -> Self {
        let bytes = try deserializer.deserializeBytes()
        return try Self(bytes)
    }

    
}