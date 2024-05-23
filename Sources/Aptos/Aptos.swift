import Foundation
import Utils
import Clients
import OpenAPIRuntime
import Foundation
import HTTPTypes
import OpenAPIURLSession

public struct Aptos: Sendable {
    public static func hello() {
        print("Hello from Aptos!")
    }
    
    public let aptosConfig: AptosConfig
    public let account: Account
    public let transaction: Transaction
    
    public init(aptosConfig: AptosConfig) {
        self.aptosConfig = aptosConfig
        self.account = .init(config: aptosConfig)
        self.transaction = .init(config: aptosConfig)
    }
}

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
    public let network: Network
    
    private let clientMiddleware: any ClientMiddleware
    private let _client: any ClientInterface
    
    public init(
        network: Network = .init(),
        transprot: any ClientTransport = URLSessionTransport(),
        clientConfig: ClientConfig? = nil,
        fullnodeConfig: ClientHeadersType? = nil,
        indexerConfig: ClientHeadersType? = nil,
        faucetConfig: FaucetConfig? = nil
    ) {
        self.network = network
        
        self.clientMiddleware = ClientConfigMiddleware(
            network: network,
            clientConfig: clientConfig,
            fullnodeConfig: fullnodeConfig,
            indexerConfig: indexerConfig,
            faucetConfig: faucetConfig
        )
        
        guard let serverURL = URL(string: network.api) else {
            fatalError("Failed to create an URL with the string '\(network.api)'.")
        }
        
        self._client = Client(
            serverURL: serverURL,
            configuration: Configuration(),
            transport: transprot,
            middlewares: [clientMiddleware]
        )
    }
    
    var client: any ClientInterface {
        return _client
    }
}

struct ClientConfigMiddleware: ClientMiddleware {
    
    let network: Network
    let clientConfig: ClientConfig?
    let fullnodeConfig: ClientHeadersType?
    let indexerConfig: ClientHeadersType?
    let faucetConfig: FaucetConfig?
    
    init(
        network: Network,
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

public protocol AptosCapability {
    var config: AptosConfig { get }
}

extension AptosCapability {
    var client: any ClientInterface {
        return config.client
    }
}


extension ClientInterface {
    private func sendRequest<Body>(_ request: any _RequestOptions) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await send(input: request) { input in
            return try input.serializer(with: converter)
        } deserializer: { resp, httpBody in
            if case .successful = resp.status.kind {
                return try await converter.getResponseBodyAsJSON(
                    Body.self,
                    from: httpBody
                ) { body in
                    return AptosResponse(
                        requestOptions: request,
                        body: body,
                        response: resp,
                        responseBody: httpBody
                    )
                }
            } else {
                let apiError = try await converter.getResponseBodyAsJSON(
                    AptosApiError.Body.self,
                    from: httpBody) { body in
                    return AptosApiError(
                        body: body,
                        requestOptions: request,
                        response: resp,
                        responseBody: httpBody
                    )
                }
                throw apiError
            }
        }
    }
    
    func sendPaginateRequest<Body>(
        _ request: inout RequestOptions & PagenationRequest
    ) async throws  -> AptosResponse<[Body]> where Body: Decodable {
        var cursor: String?
        var query = request.query ?? [:]
        var result: [Body] = []
        
        repeat {
            let resp: AptosResponse<[Body]> = try await get(request)
            cursor = resp.response?.headerFields[HTTPField.Name.Aptos.cursor]
            query["start"] = cursor
            result.append(contentsOf: resp.body)
            request.query = query
        } while (cursor != nil)
        
        return .init(requestOptions: request, body: result)
    }
    
    func get<Body>(
        _ request: any RequestOptions
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(request)
    }
    
    func post<Body>(
        _ request: any PostRequestOptions
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(request)
    }
}

public typealias Pagination = (offset: String, limit: Int)


protocol PagenationRequest {
    var page: Pagination? { get }
    var query: Parameter? {set get}
}
