

import Foundation
import Types
import Clients
import Core

extension Transaction {
    public struct Submit: Sendable {
        let aptosConfig: AptosConfig
        let client: any ClientInterface
    }
}

extension Transaction.Submit: TransactionSubmitter {

    public func simple(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        feePayerAuthenticator: AccountAuthenticator? = nil
    ) async throws -> PendingTransaction {
        // TODO: validate fee payer data on submission
        return try await submitTransaction(
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
        return try await submitTransaction(
            transaction: transaction,
            senderAuthenticator: senderAuthenticator,
            feePayerAuthenticator: feePayerAuthenticator,
            additionalSignersAuthenticators: additionalSignersAuthenticators
        )
    }
}
