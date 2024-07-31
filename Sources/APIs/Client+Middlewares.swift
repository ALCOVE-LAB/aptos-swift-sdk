
import Foundation
import HTTPTypes
import Types
import Clients
import OpenAPIRuntime
import Utils

package struct ClientConfigMiddleware: ClientMiddleware {
    private let network: AptosConfig.Network
    private let clientConfig: ClientConfig?
    private let fullnodeConfig: ClientHeadersType?
    private let indexerConfig: ClientHeadersType?
    private let faucetConfig: FaucetConfig?
    
    package init(
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
    
   package func intercept(
        _ request: HTTPTypes.HTTPRequest,
         body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (
            HTTPTypes.HTTPRequest,
            OpenAPIRuntime.HTTPBody?, URL
        ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
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

package struct FaucetMiddleware: ClientMiddleware {
    
    package init() {}

    package func intercept(
        _ request: HTTPTypes.HTTPRequest,
         body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (
            HTTPTypes.HTTPRequest,
            OpenAPIRuntime.HTTPBody?, URL
        ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var request = request
        
        request.headerFields.removeAll(where: { $0.name == .authorization })
        
        return try await next(request, body, baseURL)
    }
    
}
