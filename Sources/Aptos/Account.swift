
import Foundation
import Clients
import OpenAPIRuntime
import Types
public struct AccountApi: Sendable, AccountAPIProtocol {
    let config: AptosConfig
    public let client: any ClientInterface
    
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
    }
}

