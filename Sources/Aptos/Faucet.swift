import Foundation
import Clients
import Types
import Core
import APIs
import Utils

extension Aptos {
    public struct Faucet: Sendable, FaucetAPIProtocol {
        private let config: AptosConfig
        public let faucetClient: any ClientInterface
        public let transaction: TransactionAPIProtocol

        init(config: AptosConfig, transaction: TransactionAPIProtocol) {
            self.config = config
            self.transaction = transaction

            let middleware = ClientConfigMiddleware(
                network: config.network,
                clientConfig: config.clientConfig,
                fullnodeConfig: config.fullnodeConfig,
                indexerConfig: config.indexerConfig,
                faucetConfig: config.faucetConfig
            )
            
            guard let serverURL =  URL(string: config.network.faucetApi) else {
                fatalError("Failed to create an URL with the string '\(config.network.faucetApi)'.")
            }
            
            self.faucetClient = Client(
                serverURL: serverURL,
                transport: config.transport,
                middlewares: [middleware, FaucetMiddleware()]
            )
        }
    }
}