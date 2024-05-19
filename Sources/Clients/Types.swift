
@_spi(Generated) import OpenAPIRuntime
import Foundation
import HTTPTypes
import OpenAPIURLSession

package protocol Convertible {
    func setQueryItemAsURI<T: Encodable>(
        in request: inout HTTPRequest,
        style: ParameterStyle?,
        explode: Bool?,
        name: String,
        value: T?
    ) throws
    
    func setAcceptHeader<T: AcceptableProtocol>(
        in headerFields: inout HTTPFields,
        contentTypes: [AcceptHeaderContentType<T>]
    )
    
    func setRequiredRequestBodyAsBinary(
        _ value: HTTPBody,
        headerFields: inout HTTPFields,
        contentType: String)
        throws -> HTTPBody
    
    func setRequiredRequestBodyAsJSON<T: Encodable>(
        _ value: T,
        headerFields: inout HTTPFields,
        contentType: String
    ) throws -> HTTPBody
    
    
    func getResponseBodyAsJSON<T: Decodable, C>(
        _ type: T.Type,
        from data: HTTPBody?,
        transforming transform: (T) -> C
    ) async throws -> C
}

extension Converter: Convertible {}

package protocol RequestSerializable: Sendable {
    func serializer(with converter: Convertible) throws -> (HTTPRequest, HTTPBody?)
}

package protocol _RequestOptions: Sendable {
    var path: String {get}
    
    var query: [String: Encodable]? { get }
    
    var contentType: MimeType { get }
    
    var acceptType: MimeType { get }
    
    var headers: HTTPFields? { get }
}

package extension _RequestOptions {
    
    var params: [String: Encodable]? {
        return nil
    }
    
    var acceptType: MimeType {
        return .json
    }
    
    var contentType: MimeType {
        return .json
    }
    var headers: HTTPFields? {
        return nil
    }
}

package extension _RequestOptions {
    func serializer(with converter: Convertible) throws -> (HTTPRequest, HTTPBody?) {
        var request: HTTPTypes.HTTPRequest = .init(soar_path: path, method: .get, headerFields: headers ?? .init())

        switch self {
        case is RequestOptions:
            fallthrough
        case is PostRequestOptions:
            request.method = .post
        default:
            preconditionFailure("Unsupported type: \(type(of: self))")
        }
        
        try converter.setAcceptHeader(in: &request.headerFields, contentTypes: [.init(contentType: acceptType)])
        
        try params?.map({ (key, value) in
            try converter.setQueryItemAsURI(in: &request, style: .form, explode: true, name: key, value: value)
        })
        
        var body: HTTPBody?
        if let postReuqest = self as? PostRequestOptions {
            switch postReuqest.body {
            case .json(let value):
                let data = try JSONSerialization.data(withJSONObject: value)
                body = try converter.setRequiredRequestBodyAsBinary(
                    .init(data), headerFields: &request.headerFields, contentType: contentType.rawValue
                )
            case .codable(let value):
                body = try converter.setRequiredRequestBodyAsJSON(
                    value, headerFields: &request.headerFields, contentType: contentType.rawValue)
            case .binary(let httpBody):
                body = try converter.setRequiredRequestBodyAsBinary(
                    httpBody, headerFields: &request.headerFields, contentType: contentType.rawValue)
            case .none:
                break
            }
        }
        return (request, body)
    }
    
}

package protocol RequestOptions: RequestSerializable, _RequestOptions {}

package protocol PostRequestOptions: _RequestOptions, RequestSerializable {
    var body: RequestBody? { get }
}

package extension PostRequestOptions {
    var body: RequestBody? { nil }
}

package enum RequestBody {
    case json([String: Any])
    case codable(Encodable)
    case binary(HTTPBody)
}

package protocol ClientInterface {
    var serverURL: Foundation.URL {get}
    var converter: Convertible {get}
    
    init(
        serverURL: Foundation.URL,
        configuration: Configuration,
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware]
    )
    
    func send<Input, Output>(
        input: Input,
        serializer: @Sendable (Input) throws -> (HTTPRequest, HTTPBody?),
        deserializer: @Sendable (HTTPResponse, HTTPBody?) async throws -> Output
    ) async throws -> Output where Input: Sendable, Output: Sendable
}

public struct Client: ClientInterface {
    
    public var serverURL: URL
    package var converter: Convertible {
        return client.converter
    }
    private let client: UniversalClient
    
    public init(
        serverURL: Foundation.URL,
        configuration: Configuration = .init(),
        transport: any ClientTransport = URLSessionTransport(),
        middlewares: [any ClientMiddleware] = []
    ) {
        self.serverURL = serverURL
        self.client = .init(
            serverURL: serverURL,
            configuration: configuration,
            transport: transport,
            middlewares: middlewares
        )
    }
    
    package func send<Input, Output>(
        input: Input,
        serializer: @Sendable (Input) throws -> (HTTPRequest, HTTPBody?),
        deserializer: @Sendable (HTTPResponse, HTTPBody?) async throws -> Output
    ) async throws -> Output where Input: Sendable, Output: Sendable {
        var operationID: String?
        if let request = input as? _RequestOptions {
            operationID = request.path
        }
        return try await client.send(input: input, forOperation: operationID ?? UUID().uuidString) { (input) in
            try serializer(input)
        } deserializer: { resp, body in
            try await deserializer(resp, body)
        }
    }
}

package enum MimeType: String, AcceptableProtocol {
    case json = "application/json"
    case bcs = "application/x-bcs"
    case bcsSignedTransaction = "application/x.aptos.signed_transaction+bcs"
    case bcsViewFunction = "application/x.aptos.view_function+bcs"
}

extension HTTPField.Name {
    public struct Aptos {
        public static var chainId: HTTPField.Name { .init("X-APTOS-CHAIN-ID")! }
        public static var ledgerVersion: HTTPField.Name { .init("X-APTOS-LEDGER-VERSION")! }
        public static var ledgerOldestVersion: HTTPField.Name { .init("X-APTOS-LEDGER-OLDEST-VERSION")! }
        public static var ledgerTimestampUsec: HTTPField.Name { .init("X-APTOS-LEDGER-TIMESTAMPUSEC")! }
        public static var epoch: HTTPField.Name { .init("X-APTOS-EPOCH")! }
        public static var blockHeight: HTTPField.Name { .init("X-APTOS-BLOCK-HEIGHT")! }
        public static var oldestBlockHeight: HTTPField.Name { .init("X-APTOS-OLDEST-BLOCK-HEIGHT")! }
        public static var cursor: HTTPField.Name { .init("X-APTOS-CURSOR")! }
    }
}

package struct AptosResponse<T> {
    package var requestOptions: any Sendable
    
    /// The HTTP request created during the operation.
    ///
    /// Will be nil if the error resulted before the request was generated,
    /// for example if generating the request from the Input failed.
    package var request: HTTPRequest?
    
    /// The HTTP request body created during the operation.
    ///
    /// Will be nil if the error resulted before the request was generated,
    /// for example if generating the request from the Input failed.
    package var requestBody: HTTPBody?
    
    /// The base URL for HTTP requests.
    ///
    /// Will be nil if the error resulted before the request was generated,
    /// for example if generating the request from the Input failed.
    package var baseURL: URL?
    
    package var body: T
    /// The HTTP response received during the operation.
    ///
    /// Will be nil if the error resulted before the response was received.
    package var response: HTTPResponse?
    
    /// The HTTP response body received during the operation.
    ///
    /// Will be nil if the error resulted before the response was received.
    package var responseBody: HTTPBody?
    
    package init(requestOptions: any Sendable, request: HTTPRequest? = nil, requestBody: HTTPBody? = nil, baseURL: URL? = nil, body: T, response: HTTPResponse? = nil, responseBody: HTTPBody? = nil) {
        self.requestOptions = requestOptions
        self.request = request
        self.requestBody = requestBody
        self.baseURL = baseURL
        self.body = body
        self.response = response
        self.responseBody = responseBody
    }
}

package extension AptosResponse {
    var status: Int {
        return response?.status.code ?? 0
    }
    
    var statusText: String {
        return response?.status.reasonPhrase ?? ""
    }
    
}
