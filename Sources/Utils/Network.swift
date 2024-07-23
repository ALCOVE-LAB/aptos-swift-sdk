import Foundation

extension AptosConfig {

    public enum ApiEnv: Sendable {
        case mainnet
        case testnet
        case devnet
        case randomnet
        case local
        case custom(nodeApi: String?, indexerApi: String?, faucetApi: String?)
        
        public var nodeApi: String {
            switch self {
            case .mainnet:
                return "https://api.mainnet.aptoslabs.com/v1"
            case .testnet:
                return "https://api.testnet.aptoslabs.com/v1"
            case .devnet:
                return "https://api.devnet.aptoslabs.com/v1"
            case .randomnet:
                return "https://fullnode.random.aptoslabs.com/v1"
            case .local:
                return "http://127.0.0.1:8080/v1"
            case .custom(let nodeApi, _, _):
                return nodeApi ?? ""
            }
        }
        
        public var indexerApi: String {
            switch self {
            case .mainnet:
                return "https://api.mainnet.aptoslabs.com/v1/graphql"
            case .testnet:
                return "https://api.testnet.aptoslabs.com/v1/graphql"
            case .devnet:
                return "https://api.devnet.aptoslabs.com/v1/graphql"
            case .randomnet:
                return "https://indexer-randomnet.hasura.app/v1/graphql"
            case .local:
                return "http://127.0.0.1:8090/v1/graphql"
            case .custom(_, let indexerApi, _):
                return indexerApi ?? ""
            }
        }
        
        public var faucetApi: String {
            switch self {
            case .mainnet:
                return "https://faucet.mainnet.aptoslabs.com"
            case .testnet:
                return "https://faucet.testnet.aptoslabs.com"
            case .devnet:
                return "https://faucet.devnet.aptoslabs.com"
            case .randomnet:
                return "https://faucet.random.aptoslabs.com"
            case .local:
                return "http://127.0.0.1:8081"
            case .custom(_, _, let faucetApi):
                return faucetApi ?? ""
            }
        }
    }

    public enum ApiType: Sendable {
        case fullNode
        case indexer
        case faucet
    }
}

extension AptosConfig {
    public struct Network: Sendable {
        public static let mainnet = Network(apiEnv: .mainnet)
        public static let testnet = Network(apiEnv: .testnet)
        public static let devnet = Network(apiEnv: .devnet)
        public static let localnet = Network(apiEnv: .local)

        public let apiEnv: ApiEnv
        
        public static func custom(
            apiEnv: ApiEnv
        ) -> Network {
            let config = self.init(apiEnv: apiEnv)
            return config
        }
        
        public init(apiEnv: ApiEnv = .devnet) {
            self.apiEnv = apiEnv
        }
        
        public var name: String {
            switch apiEnv {
            case .mainnet:
                "mainnet"
            case .testnet:
                "testnet"
            case .devnet:
                "devnet"
            case .randomnet:
                "randomnet"
            case .local:
                "local"
            case .custom:
                "custom"
            }
        }

        public var fullNodeApi: String {
            apiEnv.nodeApi
        }
        public var indexerApi: String {
            apiEnv.indexerApi
        }
        public var faucetApi: String {
            apiEnv.faucetApi
        }
        
        public func apiType(with url: URL) -> ApiType? {
            if case .custom = apiEnv {
                return nil
            }
            if apiEnv.nodeApi == url.absoluteString {
                return .fullNode
            }
            if apiEnv.indexerApi == url.absoluteString {
                return .indexer
            }
            if apiEnv.faucetApi == url.absoluteString {
                return .faucet
            }
            return nil
        }
        
        public var chainId: UInt8? {
            switch apiEnv {
            case .mainnet:
                return 1
            case .testnet:
                return 2
            case .randomnet:
                return 70
            case .local:
                return 4
            default:
                return nil
            }
        }
    }
}
