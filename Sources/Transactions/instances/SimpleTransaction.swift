import Foundation
import BCS
import Core

public struct SimpleTransaction: Serializable, Deserializable {
    public let rawTransaction: RawTransaction
    public var feePayerAddress: AccountAddress?
    
    public init(
        rawTransaction: RawTransaction,
        feePayerAddress: AccountAddress?
    ) {
        self.rawTransaction = rawTransaction
        self.feePayerAddress = feePayerAddress
    }
    
    public func serialize(serializer: Serializer) throws {
        try rawTransaction.serialize(serializer: serializer)
        if let feePayerAddress = feePayerAddress {
            try serializer.serializeBool(value: true)
            try feePayerAddress.serialize(serializer: serializer)
        } else {
            try serializer.serializeBool(value: false)
        }
    }
    
    public static func deserialize(deserializer: Deserializer) throws -> SimpleTransaction {
        let rawTransaction = try RawTransaction.deserialize(deserializer: deserializer)
        let hasFeePayer = try deserializer.deserializeBool()
        let feePayerAddress: AccountAddress?
        if hasFeePayer {
            feePayerAddress = try AccountAddress.deserialize(deserializer: deserializer)
        } else {
            feePayerAddress = nil
        }
        return .init(
            rawTransaction: rawTransaction,
            feePayerAddress: feePayerAddress
        )
    }
}
