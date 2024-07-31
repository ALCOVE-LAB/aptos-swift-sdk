import Foundation
import Clients
import Utils
import Core
import Transactions

extension Aptos.Transaction {
    public struct Build: Sendable {
        private let builder: TransactionBuilder
        init(aptosConfig: AptosConfig, client: any ClientInterface) {
            self.builder = Builder(aptosConfig: aptosConfig, client: client)
        }
    }
}

private struct Builder: TransactionBuilder {
    let aptosConfig: AptosConfig
    let client: any ClientInterface
}
extension Aptos.Transaction.Build {

    public func simple(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) async throws -> SimpleTransaction {
        return try await builder.generateTransaction(args: .init(sender: sender, data: data, options: options, withFeePayer: withFeePayer))
    }

    public func multiAgent(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        secondarySignerAddresses: [AccountAddressInput],
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) async throws -> MultiAgentTransaction {
        return try await builder.generateTransactionPayload(
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
