import Foundation
import Types
import Clients
import Core


protocol TransactionSubmitter: TransactionBuilder {
    var client: any ClientInterface { get }
    var aptosConfig: AptosConfig { get }
}

extension TransactionSubmitter {
    func signTransaction(signer: AccountProtocol, transaction: AnyRawTransaction) async throws -> AccountAuthenticator {
        let accountAuthenticator = try await sign(signer: signer, transaction: transaction)
        return accountAuthenticator
    }

    func submitTransaction(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        feePayerAuthenticator: AccountAuthenticator?,
        additionalSignersAuthenticators: [AccountAuthenticator]? = nil
    ) async throws -> PendingTransaction {
        let signedTransaction = try await generateSignedTransaction(
          transaction: transaction, 
          senderAuthenticator: senderAuthenticator, 
          feePayerAuthenticator: feePayerAuthenticator, 
          additionalSignersAuthenticators: additionalSignersAuthenticators
        )
        return  try await client.post(path: "/transactions", bobdy: .binary(.init(signedTransaction)), contentType: .bcsSignedTransaction).body
    }
}
