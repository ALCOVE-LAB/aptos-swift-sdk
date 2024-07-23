

import Foundation
import Clients
import OpenAPIRuntime
import APIs
import Transactions
import Utils

extension Aptos {
    public struct General: Sendable, GerneralAPIProtocol, TransactionBuilder {
        public let aptosConfig: AptosConfig
        public let client: any ClientInterface
        
        init(config: AptosConfig) {
            self.aptosConfig = config

            let middleware = ClientConfigMiddleware(
                network: config.network,
                clientConfig: config.clientConfig,
                fullnodeConfig: config.fullnodeConfig,
                indexerConfig: config.indexerConfig,
                faucetConfig: config.faucetConfig
            )
            
            guard let serverURL = URL(string: config.network.fullNodeApi) else {
                fatalError("Failed to create an URL with the string '\(config.network.fullNodeApi)'.")
            }
            
            self.client = Client(
                serverURL: serverURL,
                configuration: Configuration(),
                transport: config.transport,
                middlewares: [middleware]
            )
        }
    }
}
