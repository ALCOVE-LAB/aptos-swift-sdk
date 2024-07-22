
import Foundation
import Types
import Clients
import Core
import Transactions

extension Transaction {
    public struct Sign: Sendable {
        public let aptosConfig: AptosConfig
        public let client: any ClientInterface
    }
}

extension Transaction.Sign: TransactionSubmitter {

    public func transaction(signer: AccountProtocol, transaction: AnyRawTransaction) async throws -> AccountAuthenticator {
        return try await signTransaction(signer: signer, transaction: transaction)
    }

    public func transactionAsFeePayer(signer: AccountProtocol, transaction: inout AnyRawTransaction) async throws -> AccountAuthenticator {
        if transaction.feePayerAddress == nil {
            fatalError("Transaction \(transaction) is not a Fee Payer transaction")
        }
        
        transaction.feePayerAddress = signer.accountAddress

        return try await signTransaction(signer: signer, transaction: transaction)
    }
}


