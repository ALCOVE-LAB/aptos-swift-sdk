
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

package struct AptosApiError: Sendable, Error {
    package let body: Body
    package var requestOptions: any Sendable
    package var request: HTTPRequest?
    package var requestBody: HTTPBody?
    package var baseURL: URL?
    package var response: HTTPResponse?
    package var responseBody: HTTPBody?
    
    package init(
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

package extension AptosApiError {
    struct Body: Codable, Hashable, Sendable {
        /// A message describing the error
        ///
        /// - Remark: Generated from `#/components/schemas/AptosError/message`.
        package var message: String
        /// - Remark: Generated from `#/components/schemas/AptosError/error_code`.
        package var errorCode: ErrorCode
        /// A code providing VM error details when submitting transactions to the VM
        ///
        /// - Remark: Generated from `#/components/schemas/AptosError/vm_error_code`.
        package var vmErrorCode: Int?
        /// Creates a new `AptosError`.
        ///
        /// - Parameters:
        ///   - message: A message describing the error
        ///   - error_code:
        ///   - vm_error_code: A code providing VM error details when submitting transactions to the VM
        package init(
            message: String,
            errorCode: ErrorCode,
            vmErrorCode: Int? = nil
        ) {
            self.message = message
            self.errorCode = errorCode
            self.vmErrorCode = vmErrorCode
        }
        package enum CodingKeys: String, CodingKey {
            case message
            case errorCode = "error_code"
            case vmErrorCode = "vm_error_code"
        }
    }
}

extension AptosApiError {
    /// These codes provide more granular error information beyond just the HTTP
    /// status code of the response.
    package enum ErrorCode: String, Codable, Hashable, Sendable {
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
