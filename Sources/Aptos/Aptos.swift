import Foundation
import Utils
import Clients
import OpenAPIRuntime
import HTTPTypes
import OpenAPIURLSession
import Types

public struct Aptos: Sendable {
    public let aptosConfig: AptosConfig
    public let account: Aptos.Account
    public let transaction: Transaction
    public let faucet: Faucet
    public let general: Aptos.General
    
    public init(aptosConfig: AptosConfig) {
        self.aptosConfig = aptosConfig
        self.account = .init(config: aptosConfig)
        self.transaction = .init(config: aptosConfig)
        self.faucet = .init(config: aptosConfig, transaction: transaction)
        self.general = .init(config: aptosConfig)
    }
}

struct ClientConfigMiddleware: ClientMiddleware {
    
    let network: AptosConfig.Network
    let clientConfig: ClientConfig?
    let fullnodeConfig: ClientHeadersType?
    let indexerConfig: ClientHeadersType?
    let faucetConfig: FaucetConfig?
    
    init(
        network: AptosConfig.Network,
        clientConfig: ClientConfig?,
        fullnodeConfig: ClientHeadersType?,
        indexerConfig: ClientHeadersType?,
        faucetConfig: FaucetConfig?) {
            self.network = network
            self.clientConfig = clientConfig
            self.fullnodeConfig = fullnodeConfig
            self.indexerConfig = indexerConfig
            self.faucetConfig = faucetConfig
        }
    
    func intercept(_ request: HTTPTypes.HTTPRequest, body: OpenAPIRuntime.HTTPBody?, baseURL: URL, operationID: String, next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var request = request
        
        func addHeaders(key: String, value: String) {
            if let name = HTTPField.Name.init(key) {
                request.headerFields.append(.init(name: name, value: value))
            }
        }
        clientConfig?.HEADERS.forEach(addHeaders)
        
        if let apiType = network.apiType(with: baseURL) {
            switch apiType {
            case .fullNode:
                fullnodeConfig?.forEach(addHeaders)
            case .indexer:
                indexerConfig?.forEach(addHeaders)
            case .faucet:
                faucetConfig?.HEADERS.forEach(addHeaders)
            }
        }
        
        if let bearerToken = faucetConfig?.AUTH_TOKEN, !request.headerFields.contains(.authorization) {
            request.headerFields[.authorization] = "Bearer \(bearerToken)"
        }
        
        if let apiKey = clientConfig?.API_KEY, !request.headerFields.contains(.authorization) {
            request.headerFields[.authorization] = "Bearer \(apiKey)"
        }
        
        return try await next(request, body, baseURL)
    }
    
}