
import Foundation

public struct EntryFunctionBytes: Serializable {
    public let value: FixedBytes
    
    public init(value: [UInt8]) {
        self.value = FixedBytes(value: value)
    }
    
    public func serialize(serializer: Serializer) throws {
        try serializer.serialize(value: value)
    }
    
    public static func deserialize(deserializer: Deserializer, length: Int) throws -> EntryFunctionBytes {
        let bytes = try FixedBytes.deserialize(deserializer: deserializer, length: length)
        return .init(value: bytes.value)
    }
}
