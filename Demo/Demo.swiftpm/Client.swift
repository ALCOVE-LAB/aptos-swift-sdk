//
//  Client.swift
//  
//
//  Created by wanglei on 2024/5/14.
//

import Foundation
import HTTPTypes
/*
//import OpenAPIRuntime
//import OpenAPIURLSession

protocol ClientTransport: Sendable {

    /// Sends the underlying HTTP request and returns the received
    /// HTTP response.
    /// - Parameters:
    ///   - request: An HTTP request.
    ///   - body: An HTTP request body.
    ///   - baseURL: A server base URL.
    ///   - operationID: The identifier of the OpenAPI operation.
    /// - Returns: An HTTP response and its body.
    /// - Throws: An error if sending the request and receiving the response fails.
    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL) async throws -> (
        HTTPResponse, HTTPBody?
    )
}



struct HTTPBody {
    
}

//extension URLSessionTransport: ClientTransport {}


struct Client {
    
    public init(
        serverURL: Foundation.URL,
        configuration: Configuration = .init(),
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = []
    ) {
        self.client = .init(
            serverURL: serverURL,
            configuration: configuration,
            transport: transport,
            middlewares: middlewares
        )
    }
    private var converter: Converter {
        client.converter
    }
    
    private let client: InternalClient
}


/*
extension Client {
    func `get`<Input, Output>() async throws -> Output where Input: Sendable, Output: Sendable {
        
        try await client.send(
            input: input,
            forOperation: Operations.getGreeting.id,
            serializer: { input in
                let path = try converter.renderedPath(
                    template: "/greet",
                    parameters: []
                )
                var request: HTTPTypes.HTTPRequest = .init(
                    soar_path: path,
                    method: .get
                )
                suppressMutabilityWarning(&request)
                try converter.setQueryItemAsURI(
                    in: &request,
                    style: .form,
                    explode: true,
                    name: "name",
                    value: input.query.name
                )
                converter.setAcceptHeader(
                    in: &request.headerFields,
                    contentTypes: input.headers.accept
                )
                return (request, nil)
            },
            deserializer: { response, responseBody in
                switch response.status.code {
                case 200:
                    let contentType = converter.extractContentTypeIfPresent(in: response.headerFields)
                    let body: Operations.getGreeting.Output.Ok.Body
                    let chosenContentType = try converter.bestContentType(
                        received: contentType,
                        options: [
                            "application/json"
                        ]
                    )
                    switch chosenContentType {
                    case "application/json":
                        body = try await converter.getResponseBodyAsJSON(
                            Components.Schemas.Greeting.self,
                            from: responseBody,
                            transforming: { value in
                                .json(value)
                            }
                        )
                    default:
                        preconditionFailure("bestContentType chose an invalid content type.")
                    }
                    return .ok(.init(body: body))
                default:
                    return .undocumented(
                        statusCode: response.status.code,
                        .init(
                            headerFields: response.headerFields,
                            body: responseBody
                        )
                    )
                }
            }
        )
    }
}
*/

protocol ClientMiddleware: Sendable {

   /// Intercepts an outgoing HTTP request and an incoming HTTP response.
   /// - Parameters:
   ///   - request: An HTTP request.
   ///   - body: An HTTP request body.
   ///   - baseURL: A server base URL.
   ///   - operationID: The identifier of the OpenAPI operation.
   ///   - next: A closure that calls the next middleware, or the transport.
   /// - Returns: An HTTP response and its body.
   /// - Throws: An error if interception of the request and response fails.
   func intercept(
       _ request: HTTPRequest,
       body: HTTPBody?,
       baseURL: URL,
       operationID: String,
       next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
   ) async throws -> (HTTPResponse, HTTPBody?)
}



struct InternalClient {
    let serverURL: Foundation.URL
    let middlewares: [any ClientMiddleware]
    let transport: ClientTransport
    let converter: Converter
    
    init(
        serverURL: Foundation.URL,
        configuration: Configuration = .init(),
        transport: any ClientTransport,
        middlewares: [any ClientMiddleware] = []
    ) {
        self.serverURL = serverURL
        self.converter = .init(configuration: configuration)
        self.transport = transport
        self.middlewares = middlewares
    }
        
    
    func send<Input, Output>(
        serializer: @Sendable (Input) throws -> (HTTPRequest, HTTPBody?),
        deserializer: @Sendable (HTTPResponse, HTTPBody?) async throws -> Output
    ) async throws -> Output where Input: Sendable, Output: Sendable {
        // TODO:
        fatalError()
    }
}


#if canImport(Darwin)
import class Foundation.JSONEncoder
#else
@preconcurrency import class Foundation.JSONEncoder
#endif
import class Foundation.JSONDecoder

/// Converter between generated and HTTP currency types.
struct Converter: Sendable {

    /// Configuration used to set up the converter.
    public let configuration: Configuration

    /// JSON encoder.
    internal var encoder: JSONEncoder

    /// JSON decoder.
    internal var decoder: JSONDecoder

    /// JSON encoder used for header fields.
    internal var headerFieldEncoder: JSONEncoder

    /// Creates a new converter with the behavior specified by the configuration.
    public init(configuration: Configuration) {
        self.configuration = configuration

        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
//        self.encoder.dateEncodingStrategy = .from(dateTranscoder: configuration.dateTranscoder)

        self.headerFieldEncoder = JSONEncoder()
        self.headerFieldEncoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
//        self.headerFieldEncoder.dateEncodingStrategy = .from(dateTranscoder: configuration.dateTranscoder)

        self.decoder = JSONDecoder()
//        self.decoder.dateDecodingStrategy = .from(dateTranscoder: configuration.dateTranscoder)
    }
}

extension Converter {
    // TODO:
}

struct Configuration: Sendable {
    
    /// The transcoder used when converting between date and string values.
//    public var dateTranscoder: any DateTranscoder
//
//    /// The generator to use when creating mutlipart bodies.
//    public var multipartBoundaryGenerator: any MultipartBoundaryGenerator
//
//    /// Custom XML coder for encoding and decoding xml bodies.
//    public var xmlCoder: (any CustomCoder)?

    /// Creates a new configuration with the specified values.
    ///
    /// - Parameters:
    ///   - dateTranscoder: The transcoder to use when converting between date
    ///   and string values.
    ///   - multipartBoundaryGenerator: The generator to use when creating mutlipart bodies.
    ///   - xmlCoder: Custom XML coder for encoding and decoding xml bodies. Only required when using XML body payloads.
    public init(
//        dateTranscoder: any DateTranscoder = .iso8601,
//        multipartBoundaryGenerator: any MultipartBoundaryGenerator = .random,
//        xmlCoder: (any CustomCoder)? = nil
    ) {
//        self.dateTranscoder = dateTranscoder
//        self.multipartBoundaryGenerator = multipartBoundaryGenerator
//        self.xmlCoder = xmlCoder
    }
}


struct AptosResponse {
    
}


struct AptosRequest {
    
}


protocol AcceptableProtocol: RawRepresentable, Sendable, Hashable, CaseIterable where RawValue == String {}

enum MimeType: String, AcceptableProtocol {
    case json = "application/json"
    case bcs = "application/x-bcs"
    case bcsSignedTransaction = "application/x.aptos.signed_transaction+bcs"
    case bcsViewFunction = "application/x.aptos.view_function+bcs"
}
*/
