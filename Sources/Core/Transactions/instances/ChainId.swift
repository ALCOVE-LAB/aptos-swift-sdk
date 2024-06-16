import Foundation
import BCS

public struct ChainId: Equatable, Serializable, Deserializable {
    public let id: UInt8

    public init(id: UInt8) {
        self.id = id
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeU8(value: id)
    }
    public static func deserialize(deserializer: Deserializer) throws -> ChainId {
        let id = try deserializer.deserializeU8()
        return ChainId(id: id)
    }
}
