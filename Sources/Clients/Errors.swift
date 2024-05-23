
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

public struct AptosApiError: Error {
    public let body: Body
    public let baseURL: URL?
    public let requestOptions: any Sendable
    
    package var request: HTTPRequest?
    package var requestBody: HTTPBody?
    package var response: HTTPResponse?
    package var responseBody: HTTPBody?
    
    public init(
        body: Body,
        requestOptions: any Sendable,
        request: HTTPRequest? = nil,
        requestBody: HTTPBody? = nil,
        baseURL: URL? = nil,
        response: HTTPResponse? = nil,
        responseBody: HTTPBody? = nil
    ) {
        self.body = body
        self.requestOptions = requestOptions
        self.request = request
        self.requestBody = requestBody
        self.baseURL = baseURL
        self.response = response
        self.responseBody = responseBody
    }
}

extension AptosApiError {
    public var status: Int? {
        return response?.status.code
    }
}

extension AptosApiError {
    public struct Body: Codable, Hashable, Sendable {
        /// A message describing the error
        public var message: String
        public var errorCode: ErrorCode
        /// A code providing VM error details when submitting transactions to the VM
        public var vmErrorCode: Int?
        /// Creates a new `AptosApiError.Body`.
        ///
        /// - Parameters:
        ///   - message: A message describing the error
        ///   - errorCode:
        ///   - vmErrorCode: A code providing VM error details when submitting transactions to the VM
        public init(
            message: String,
            errorCode: ErrorCode,
            vmErrorCode: Int? = nil
        ) {
            self.message = message
            self.errorCode = errorCode
            self.vmErrorCode = vmErrorCode
        }
        
        public enum CodingKeys: String, CodingKey {
            case message
            case errorCode = "error_code"
            case vmErrorCode = "vm_error_code"
        }
    }
}

extension AptosApiError {
    /// These codes provide more granular error information beyond just the HTTP
    /// status code of the response.
    public enum ErrorCode: String, Codable, Hashable, Sendable {
        case accountNotFound = "account_not_found"
        case resourceNotFound = "resource_not_found"
        case moduleNotFound = "module_not_found"
        case structFieldNotFound = "struct_field_not_found"
        case versionNotFound = "version_not_found"
        case transactionNotFound = "transaction_not_found"
        case tableItemNotFound = "table_item_not_found"
        case blockNotFound = "block_not_found"
        case stateValueNotFound = "state_value_not_found"
        case versionPruned = "version_pruned"
        case blockPruned = "block_pruned"
        case invalidInput = "invalid_input"
        case invalidTransactionUpdate = "invalid_transaction_update"
        case sequenceNumberTooOld = "sequence_number_too_old"
        case vmError = "vm_error"
        case healthCheckFailed = "health_check_failed"
        case mempoolIsFull = "mempool_is_full"
        case internalError = "internal_error"
        case webFrameworkError = "web_framework_error"
        case bcsNotSupported = "bcs_not_supported"
        case apiDisabled = "api_disabled"
    }

}

extension AptosApiError: CustomStringConvertible {
    var vmErrorCodeStr: String? {
        guard let vmErrorCode = body.vmErrorCode else { return nil }
        return "\(vmErrorCode)"
    }
    /// A human-readable description of the api error.
    ///
    /// This computed property returns a string that includes information about the aptos api error.
    ///
    /// - Returns: A string describing the aptos api error and its associated details.
    public var description: String {
        "Aptos error - message: '\(body.message)', errCode: '\(body.errorCode)', vmErrorCode: '\(vmErrorCodeStr ?? "<nill>")', requestOptions: \(String(describing: requestOptions)), request: \(request?.prettyDescription ?? "<nil>"), requestBody: \(requestBody?.prettyDescription ?? "<nil>"), baseURL: \(baseURL?.absoluteString ?? "<nil>"), response: \(response?.prettyDescription ?? "<nil>"), responseBody: \(responseBody?.prettyDescription ?? "<nil>")"
    }
}

extension AptosApiError: LocalizedError {
    /// A localized description of the aptos api error.
    ///
    /// This computed property provides a localized human-readable description of the aptos api error, which is suitable for displaying to users.
    ///
    /// - Returns: A localized string describing the aptos api error.
    public var errorDescription: String? { description }
}


private extension HTTPRequest {
    var prettyDescription: String { "\(method.rawValue) \(path ?? "<nil>") [\(headerFields.prettyDescription)]" }
}

private extension HTTPBody { var prettyDescription: String { String(describing: self) } }

private extension HTTPFields {
    var prettyDescription: String {
        sorted(by: { $0.name.canonicalName.localizedCompare($1.name.canonicalName) == .orderedAscending })
            .map { "\($0.name.canonicalName): \($0.value)" }.joined(separator: "; ")
    }
}

private extension HTTPResponse {
    var prettyDescription: String { "\(status.code) [\(headerFields.prettyDescription)]" }
}
