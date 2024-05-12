
public protocol Network {
    var name: String { get }
    var chainId: Int { get }
    var api: String { get }
}

public enum NetworkType: String {
    case mainnet = "mainnet"
    case testnet = "testnet"
    case devnet = "devnet"
    case randomnet = "randomnet"
    case local = "local"
    case custom = "custom"
    
    var nodeApi: String {
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
        case .custom:
            return ""
        }
    }
    
    var indexerApi: String {
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
        case .custom:
            return ""
        }
    }
    
    var faucetApi: String {
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
        case .custom:
            return ""
        }
    }
}


public enum NetworkAccess {
    case rest
    case indexer
    case faucet
}

public struct NetworkOptions: Network {
    
    public let networkType: NetworkType
    public let networkAccess: NetworkAccess
    private var _api: String?
    
    public static func custom(
        networkType: NetworkType = .custom,
        networkAccess: NetworkAccess = .rest,
        chainId: Int = 0,
        api: String) -> NetworkOptions {
        var config = self.init(networkType: networkType, networkAccess: networkAccess)
        config._api = api
        return config
    }
    
    public init(networkType: NetworkType, networkAccess: NetworkAccess) {
        self.networkType = networkType
        self.networkAccess = networkAccess
    }
    
    
    public var name: String {
        return networkType.rawValue
    }
    
    public var api: String {
        if let api = _api {
            return api
        }
        switch networkAccess {
        case .rest:
            return networkType.nodeApi
        case .indexer:
            return networkType.indexerApi
        case .faucet:
            return networkType.faucetApi
        }
    }
    
    public var chainId: Int {
        switch networkType {
        case .mainnet:
            return 1
        case .testnet:
            return 2
        case .randomnet:
            return 70
        case .local:
            return 4
        case .devnet:
            return 0
        case .custom:
            return 0
        }
    }
}
