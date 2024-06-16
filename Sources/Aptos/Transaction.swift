import Foundation
import Types
import Clients
import OpenAPIRuntime


public struct Transaction: TransactionAPIProtocol, Sendable {
    let config: AptosConfig
    public let client: any ClientInterface
    public let build: Build
    public let sign: Sign
    public let submit: Submit

    init(config: AptosConfig) {
        self.config = config
        let middleware = ClientConfigMiddleware(
            network: config.network,
            clientConfig: config.clientConfig,
            fullnodeConfig: config.fullnodeConfig,
            indexerConfig: config.indexerConfig,
            faucetConfig: config.faucetConfig
        )
        
        guard let serverURL = URL(string: config.network.api) else {
            fatalError("Failed to create an URL with the string '\(config.network.api)'.")
        }
        
        self.client = Client(
            serverURL: serverURL,
            configuration: Configuration(),
            transport: config.transport,
            middlewares: [middleware]
        )
        self.build = .init(aptosConfig: config, client: client)
        self.sign = .init(aptosConfig: config, client: client)
        self.submit = .init(aptosConfig: config, client: client)
    }
}


// extension Transaction {
//     public struct Build {
//         let aptosConfig: AptosConfig
//         let client: any ClientInterface
//         init(aptosConfig: AptosConfig, client: any ClientInterface) {
//             self.aptosConfig = aptosConfig
//             self.client = client
//         }
        
//         public func simple(
//             sender: AccountAddressInput,
//             data: InputGenerateTransactionPayloadData
//             options: InputGenerateTransactionOptions?
//             withFeePayer: Bool?
//         }) async throws -> SimpleTransaction {
//             return try generateTransaction(aptosConfig: aptosConfig, client: client, args: args)
//         }

//   /**
//    * Build a simple transaction
//    *
//    * @param args.sender The sender account address
//    * @param args.data The transaction data
//    * @param args.options optional. Optional transaction configurations
//    * @param args.withFeePayer optional. Whether there is a fee payer for the transaction
//    *
//    * @returns SimpleTransaction
//    */
//   async simple(args: {
//     sender: AccountAddressInput;
//     data: InputGenerateTransactionPayloadData;
//     options?: InputGenerateTransactionOptions;
//     withFeePayer?: boolean;
//   }): Promise<SimpleTransaction> {
//     return generateTransaction({ aptosConfig: this.config, ...args });
//   }

//   /**
//    * Build a multi agent transaction
//    *
//    * @param args.sender The sender account address
//    * @param args.data The transaction data
//    * @param args.secondarySignerAddresses An array of the secondary signers account addresses
//    * @param args.options optional. Optional transaction configurations
//    * @param args.withFeePayer optional. Whether there is a fee payer for the transaction
//    *
//    * @returns MultiAgentTransaction
//    */
//   async multiAgent(args: {
//     sender: AccountAddressInput;
//     data: InputGenerateTransactionPayloadData;
//     secondarySignerAddresses: AccountAddressInput[];
//     options?: InputGenerateTransactionOptions;
//     withFeePayer?: boolean;
//   }): Promise<MultiAgentTransaction> {
//     return generateTransaction({ aptosConfig: this.config, ...args });
//   }
//         */
//     }
//     public struct Simulate {}
//     public struct Submit {}
// }