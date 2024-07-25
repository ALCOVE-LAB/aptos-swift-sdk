

import Foundation
import Utils
import Clients
import Core
import Transactions
import Types

extension Transaction {
    public struct Submit: Sendable {
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

extension Transaction.Submit {

    public func simple(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        feePayerAuthenticator: AccountAuthenticator? = nil
    ) async throws -> PendingTransaction {
        // TODO: validate fee payer data on submission
        return try await submitter.submitTransaction(
            transaction: transaction,
            senderAuthenticator: senderAuthenticator,
            feePayerAuthenticator: feePayerAuthenticator
        )
    }

    public func multiAgent(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        additionalSignersAuthenticators: [AccountAuthenticator],
        feePayerAuthenticator: AccountAuthenticator? = nil
    ) async throws -> PendingTransaction {
        // TODO: validate fee payer data on submission
        return try await submitter.submitTransaction(
            transaction: transaction,
            senderAuthenticator: senderAuthenticator,
            feePayerAuthenticator: feePayerAuthenticator,
            additionalSignersAuthenticators: additionalSignersAuthenticators
        )
    }
}
