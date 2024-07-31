import Foundation
import HTTPTypes
import Clients
import OpenAPIRuntime

public typealias Pagination = (offset: String, limit: Int)
public protocol PagenationRequest {
    var page: Pagination? { get }
    var query: Parameter? {set get}
}

extension ClientInterface {

    public func convertBodyToAptosError(
        _ httpBody: HTTPBody?, 
        resp: HTTPResponse, 
        request: any _RequestOptions
    ) async throws -> AptosApiError {
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
        return apiError
    }

    public func sendRequest<Body>(_ request: any _RequestOptions) async throws -> AptosResponse<Body> where Body: Decodable {
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
                throw try await convertBodyToAptosError(httpBody, resp: resp, request: request)
            }
        }
    }
    
    public func sendPaginateRequest<Body>(
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
    
    public func get<Body>(
        _ request: any RequestOptions
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(request)
    }
    
    public func post<Body>(
        _ request: any PostRequestOptions
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(request)
    }

    public func get<Body>(
        path: String,
        query: Parameter? = nil,
        headers: HTTPFields? = nil,
        contentType: MimeType = .json,
        acceptType: MimeType = .json
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(
            ClientGetRequest(
                path: path,
                query: query,
                headers: headers,
                contentType: contentType,
                acceptType: acceptType
            )
        )
    }

    public func post<Body>(
        path: String,
        query: Parameter? = nil,
        bobdy: RequestBody? = nil,
        headers: HTTPFields? = nil,
        contentType: MimeType = .json,
        acceptType: MimeType = .json
    ) async throws -> AptosResponse<Body> where Body: Decodable {
        return try await sendRequest(
            ClientPostRequest(
                path: path,
                query: query,
                body: bobdy,
                headers: headers,
                contentType: contentType,
                acceptType: acceptType
            )
        )
    }

}

struct ClientGetRequest: RequestOptions {
    var path: String
    var query: Parameter?
    var headers: HTTPFields?
    var contentType: MimeType = .json
    var acceptType: MimeType = .json
}


struct ClientPostRequest: PostRequestOptions {
    var path: String
    var query: Parameter?
    var body: RequestBody?
    var headers: HTTPFields?
    var contentType: MimeType = .json
    var acceptType: MimeType = .json
}