
import Foundation

public struct FixedBytes: Serializable {
    public let value: [UInt8]
    
    public init(value: [UInt8]) {
        self.value = value
    }
    
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeFixedBytes(value: value)
    }
    
    public static func deserialize(deserializer: Deserializer, length: Int) throws -> FixedBytes {
        let bytes = try deserializer.deserializeFixedBytes(length)
        return .init(value: bytes)
    }
}