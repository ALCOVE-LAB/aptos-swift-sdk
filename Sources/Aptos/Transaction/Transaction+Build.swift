import Foundation
import Clients
import Utils
import Core
import Transactions

extension Transaction {
    public struct Build: Sendable {
        public let aptosConfig: AptosConfig
        public let client: any ClientInterface
        init(aptosConfig: AptosConfig, client: any ClientInterface) {
            self.aptosConfig = aptosConfig
            self.client = client
        }
        
    }
}
extension Transaction.Build: TransactionBuilder {}
extension Transaction.Build {

    public func simple(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) async throws -> SimpleTransaction {
        return try await generateTransaction(args: .init(sender: sender, data: data, options: options, withFeePayer: withFeePayer))
    }

    public func multiAgent(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        secondarySignerAddresses: [AccountAddressInput],
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) async throws -> MultiAgentTransaction {
        return try await generateTransactionPayload(
            args: .init(
                sender: sender,
                data: data,
                secondarySignerAddresses: secondarySignerAddresses,
                options: options,
                withFeePayer: withFeePayer
                )
            )
    }
}
