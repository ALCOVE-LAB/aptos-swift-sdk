import Foundation
import BCS

public struct SignedTransaction: Serializable, Deserializable {
    public let rawTransaction: RawTransaction
    public let authenticator: TransactionAuthenticator
    
    public init(
        rawTransaction: RawTransaction,
        authenticator: TransactionAuthenticator
    ) {
        self.rawTransaction = rawTransaction
        self.authenticator = authenticator
    }
    
    public func serialize(serializer: Serializer) throws {
        try rawTransaction.serialize(serializer: serializer)
        try authenticator.serialize(serializer: serializer)
    }
    
    public static func deserialize(deserializer: Deserializer) throws -> SignedTransaction {
        let rawTransaction = try deserializer.deserialize(RawTransaction.self) 
        let authenticator = try deserializer.deserialize(TransactionAuthenticator.self)
        return .init(
            rawTransaction: rawTransaction,
            authenticator: authenticator
        )
    }

}
