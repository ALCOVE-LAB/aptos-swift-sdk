import Foundation
import Clients
import OpenAPIRuntime
import OpenAPIURLSession

public typealias ClientHeadersType = [String:String]

public struct ClientConfig: Sendable {
    public var HEADERS: ClientHeadersType
    public var WITH_CREDENTIALS: Bool?
    public var API_KEY: String?
}

public struct FaucetConfig: Sendable {
    public var HEADERS: ClientHeadersType
    public var AUTH_TOKEN: String?
}

public struct AptosConfig: Sendable {

    public static let mainnet = Self.init(network: Network.mainnet)
    public static let testnet = Self.init(network: Network.testnet)
    public static let devnet = Self.init(network: Network.devnet)
    public static let localnet = Self.init(network: Network.localnet)

    public let network: Network
    
    public let transport: any ClientTransport
    public let clientConfig: ClientConfig?
    public let fullnodeConfig: ClientHeadersType?
    public let indexerConfig: ClientHeadersType?
    public let faucetConfig: FaucetConfig?
    

    public init(
        network: Network = .init(),
        transprot: any ClientTransport = URLSessionTransport(),
        clientConfig: ClientConfig? = nil,
        fullnodeConfig: ClientHeadersType? = nil,
        indexerConfig: ClientHeadersType? = nil,
        faucetConfig: FaucetConfig? = nil
    ) {
        self.network = network
        self.transport = transprot
        self.clientConfig = clientConfig
        self.fullnodeConfig = fullnodeConfig
        self.indexerConfig = indexerConfig
        self.faucetConfig = faucetConfig
    }
}
