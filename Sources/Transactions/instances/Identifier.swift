import Foundation
import BCS

public struct Identifier: Serializable, Deserializable, Sendable, Equatable {
    public let identifier: String

    public init(_ identifier: String) {
        self.identifier = identifier
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeStr(value: identifier)
    }

    public static func deserialize(deserializer: Deserializer) throws -> Identifier {
        let identifier = try deserializer.deserializeStr()
        return .init(identifier)
    }

    public static func ==(lhs: Identifier, rhs: Identifier) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
