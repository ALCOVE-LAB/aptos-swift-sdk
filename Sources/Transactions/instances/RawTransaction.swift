import Foundation
import BCS
import Types
import BigInt
import Core

public struct RawTransaction: Serializable, Deserializable {
    public let sender: AccountAddress
    public let sequenceNumber: UInt64
    public let payload: TransactionPayload
    public let maxGasAmount: UInt64
    public let gasUnitPrice: UInt64
    public let expirationTimestampSecs: UInt64
    public let chainId: ChainId

    public init(
        sender: AccountAddress,
        sequenceNumber: UInt64,
        payload: TransactionPayload,
        maxGasAmount: UInt64,
        gasUnitPrice: UInt64,
        expirationTimestampSecs: UInt64,
        chainId: ChainId
    ) {
        self.sender = sender
        self.sequenceNumber = sequenceNumber
        self.payload = payload
        self.maxGasAmount = maxGasAmount
        self.gasUnitPrice = gasUnitPrice
        self.expirationTimestampSecs = expirationTimestampSecs
        self.chainId = chainId
    }

    public func serialize(serializer: Serializer) throws {
        try sender.serialize(serializer: serializer)
        try serializer.serializeU64(value: sequenceNumber)
        try payload.serialize(serializer: serializer)
        try serializer.serializeU64(value: maxGasAmount)
        try serializer.serializeU64(value: gasUnitPrice)
        try serializer.serializeU64(value: expirationTimestampSecs)
        try chainId.serialize(serializer: serializer)
    }

    public static func deserialize(deserializer: Deserializer) throws -> RawTransaction {
        let sender = try AccountAddress.deserialize(deserializer: deserializer)
        let sequenceNumber = try deserializer.deserializeU64()
        let payload = try TransactionPayload.deserialize(deserializer: deserializer)
        let maxGasAmount = try deserializer.deserializeU64()
        let gasUnitPrice = try deserializer.deserializeU64()
        let expirationTimestampSecs = try deserializer.deserializeU64()
        let chainId = try ChainId.deserialize(deserializer: deserializer)
        return .init(
            sender: sender,
            sequenceNumber: sequenceNumber,
            payload: payload,
            maxGasAmount: maxGasAmount,
            gasUnitPrice: gasUnitPrice,
            expirationTimestampSecs: expirationTimestampSecs,
            chainId: chainId
        )
    }

}

public struct MultiAgentRawTransaction: Serializable {
    public let rawTxn: RawTransaction
    public let secondarySignerAddresses: [AccountAddress]

    public init(rawTxn: RawTransaction, secondarySignerAddresses: [AccountAddress]) {
        self.rawTxn = rawTxn
        self.secondarySignerAddresses = secondarySignerAddresses
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: TransactionVariants.multiAgent.rawValue)
        try rawTxn.serialize(serializer: serializer)
        try serializer.serializeVector(values: secondarySignerAddresses)
    }
}

public struct FeePayerRawTransaction: Serializable {
    public let rawTxn: RawTransaction
    public let secondarySignerAddresses: [AccountAddress]
    public let feePayerAddress: AccountAddress

    public init(
        rawTxn: RawTransaction,
        secondarySignerAddresses: [AccountAddress],
        feePayerAddress: AccountAddress
    ) {
        self.rawTxn = rawTxn
        self.secondarySignerAddresses = secondarySignerAddresses
        self.feePayerAddress = feePayerAddress
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: TransactionVariants.feePayer.rawValue)
        try rawTxn.serialize(serializer: serializer)
        try serializer.serializeVector(values: secondarySignerAddresses)
        try feePayerAddress.serialize(serializer: serializer)
    }
}