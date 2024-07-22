import Foundation
import BCS
import Core

/// Representation of a Raw Transaction that can serialized and deserialized
public struct MultiAgentTransaction: Serializable, Deserializable {
    public let rawTransaction: RawTransaction
    public let secondarySignerAddresses: [AccountAddress]
    public var feePayerAddress: AccountAddress?
    
    public init(
        rawTransaction: RawTransaction,
        secondarySignerAddresses: [AccountAddress],
        feePayerAddress: AccountAddress?
    ) {
        self.rawTransaction = rawTransaction
        self.secondarySignerAddresses = secondarySignerAddresses
        self.feePayerAddress = feePayerAddress
    }
    
    public func serialize(serializer: Serializer) throws {
        try rawTransaction.serialize(serializer: serializer)
        try serializer.serializeVector(values: secondarySignerAddresses)
        if let feePayerAddress = feePayerAddress {
            try serializer.serializeBool(value: true)
            try feePayerAddress.serialize(serializer: serializer)
        } else {
            try serializer.serializeBool(value: false)
        }
    }
    
    public static func deserialize(deserializer: Deserializer) throws -> MultiAgentTransaction {
        let rawTransaction = try RawTransaction.deserialize(deserializer: deserializer)
        let secondarySignerAddresses: [AccountAddress] = try deserializer.deserializeVector(AccountAddress.self)
        let hasFeePayer = try deserializer.deserializeBool()
        let feePayerAddress: AccountAddress?
        if hasFeePayer {
            feePayerAddress = try AccountAddress.deserialize(deserializer: deserializer)
        } else {
            feePayerAddress = nil
        }
        return .init(
            rawTransaction: rawTransaction,
            secondarySignerAddresses: secondarySignerAddresses,
            feePayerAddress: feePayerAddress
        )
    }
}