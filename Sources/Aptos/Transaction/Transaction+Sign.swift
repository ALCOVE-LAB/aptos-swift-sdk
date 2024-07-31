
import Foundation
import Utils
import Clients
import Core
import Transactions

extension Aptos.Transaction {
    public struct Sign: Sendable {
        private let submitter: TransactionSubmitter
        init(aptosConfig: AptosConfig, client: any ClientInterface) {
            self.submitter = Submitter(aptosConfig: aptosConfig, client: client)
        }
    }
}

private struct Submitter: TransactionSubmitter {
    let aptosConfig: AptosConfig
    let client: any ClientInterface
}

extension Aptos.Transaction.Sign {

    public func transaction(signer: AccountProtocol, transaction: AnyRawTransaction) async throws -> AccountAuthenticator {
        return try await submitter.signTransaction(signer: signer, transaction: transaction)
    }

    public func transactionAsFeePayer(signer: AccountProtocol, transaction: inout AnyRawTransaction) async throws -> AccountAuthenticator {
        if transaction.feePayerAddress == nil {
            fatalError("Transaction \(transaction) is not a Fee Payer transaction")
        }
        
        transaction.feePayerAddress = signer.accountAddress

        return try await submitter.signTransaction(signer: signer, transaction: transaction)
    }
}


