
import Foundation
import BCS

public enum ModuleIdError: Error {
    case invalidFormat
}

public struct ModuleId: Serializable, Deserializable {
    public let address: AccountAddress
    public let name: Identifier
    
    public init(address: AccountAddress, name: Identifier) {
        self.address = address
        self.name = name
    }
    
    public func serialize(serializer: Serializer) throws {
        try address.serialize(serializer: serializer)
        try name.serialize(serializer: serializer)
    }
    
    public static func deserialize(deserializer: Deserializer) throws -> ModuleId {
        let address = try AccountAddress.deserialize(deserializer: deserializer)
        let name = try Identifier.deserialize(deserializer: deserializer)
        return .init(address: address, name: name)
    }

    public static func fromStr(_ moduleId: String) throws -> ModuleId {
        let parts = moduleId.split(separator: ":")
        if parts.count != 2 {
            throw ModuleIdError.invalidFormat
        }
        let first = String(parts.first!)
        let last = String(parts.last!)
        return .init(address: try AccountAddress.fromString((first)), name: Identifier(last))
    }

}