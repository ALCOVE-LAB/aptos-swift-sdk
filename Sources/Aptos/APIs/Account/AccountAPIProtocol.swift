import Foundation
import Clients
import Types
import HTTPTypes

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
        _ request: inout any RequestOptions & PagenationRequest
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

public protocol AccountAPIProtocol: Sendable {}

extension AccountAPIProtocol where Self: ClientInterface {
    func getAccountInfo(
        address: HexInput,
        ledgerVersion: String? = nil) async throws -> AccountData {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountInfo(address: AccountAddress.from(hex.toString()), ledgerVersion: ledgerVersion)
    }
    func getAccountInfo(
        address: AccountAddressInput,
        ledgerVersion: String? = nil) async throws -> AccountData {
        return try await get(AccountApiOperation.GetAccount.info(AccountAddress.from(address))).body
    }
    

    func getAccountResources(
        address: HexInput, ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveResource] {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountResources(address: AccountAddress.from(hex.toString()), ledgerVersion: ledgerVersion, page: page)
    }
    func getAccountResources(
        address: AccountAddressInput,
        ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveResource] {
            var request: PagenationRequest & RequestOptions = 
            AccountApiOperation.GetAccountPageModule.resources(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion, page: page)
            return try await sendPaginateRequest(&request).body
    }
    
    
    func getAccountResource(
        address: HexInput, resourceType: MoveStructTag, ledgerVersion: String? = nil
    ) async throws -> MoveResource {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountResource(
            address: AccountAddress.from(hex.toString()),
            resourceType: resourceType,
            ledgerVersion: ledgerVersion)
    }
    func getAccountResource(
        address: AccountAddressInput,
        resourceType: MoveStructTag,
        ledgerVersion: String? = nil
    ) async throws -> MoveResource {
        let request: RequestOptions = AccountApiOperation.GetAccount.resource(
            try AccountAddress.from(address),
            resourceType: resourceType,
            ledgerVersion: ledgerVersion
        )
        return try await get(request).body
    }
    
    
    func getAccountModules(
        address: HexInput,
        ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveModuleBytecode] {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountModules(
            address: AccountAddress.from(hex.toString()),
            ledgerVersion: ledgerVersion,
            page: page
        )
    }
    func getAccountModules(
        address: AccountAddressInput,
        ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveModuleBytecode] {
            var request: PagenationRequest & RequestOptions =
            AccountApiOperation.GetAccountPageModule.modules(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion,
                page: page)
            return try await sendPaginateRequest(&request).body
    }
    
    func getAccountModule(
        address: HexInput, moduleName: String, ledgerVersion: String? = nil
    ) async throws -> MoveModuleBytecode {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountModule(
            address: AccountAddress.from(hex.toString()),
            moduleName: moduleName,
            ledgerVersion: ledgerVersion)
    }
    func getAccountModule(
        address: AccountAddressInput,
        moduleName: String,
        ledgerVersion: String? = nil
    ) async throws -> MoveModuleBytecode {
        //  TODO: support a cache?
        let request: RequestOptions = AccountApiOperation.GetAccount.module(
            try AccountAddress.from(address),
            moduleName: moduleName,
            ledgerVersion: ledgerVersion
        )
        return try await get(request).body
    }
}

public typealias Pagination = (offset: String, limit: Int)

protocol PagenationRequest {
    var page: Pagination? { get }
    var query: [String: Encodable]? {set get}
}

struct AccountApiOperation {
    struct GetAccountPageModule: RequestOptions, PagenationRequest {
        
        enum ModuleType {
            case reouseces
            case modules
        }
        
        static func resources(
            address: AccountAddress,
            ledgerVersion: String? = nil,
            page: Pagination? = nil) -> GetAccountPageModule {
            self.init(
                moduleType: .reouseces,
                address: address,
                ledgerVersion: ledgerVersion,
                page: page
            )
        }
        static func modules(
            address: AccountAddress,
            ledgerVersion: String? = nil,
            page: Pagination? = nil) -> GetAccountPageModule {
            return self.init(
                moduleType: .modules,
                address: address,
                ledgerVersion: ledgerVersion,
                page: page
            )
        }
        
        let address: AccountAddress
        let ledgerVersion: String?
        let page: Pagination?
        let moduleType: ModuleType
        
        private init(moduleType: ModuleType, address: AccountAddress, ledgerVersion: String? = nil, page: Pagination? = nil) {
            self.moduleType = moduleType
            self.address = address
            self.ledgerVersion = ledgerVersion
            self.page = page
            
            var query: [String: Encodable] = [:]
            if let version = ledgerVersion {
                query["ledger_version"] = ledgerVersion
            }
            if let page = page {
                query["start"] = page.offset
                query["limit"] = page.limit
            }
            self.query = query
        }
        
        var path: String {
            switch moduleType {
            case .reouseces:
                return "/accounts/\(address.toString())/resources"
            case .modules:
                return "/accounts/\(address.toString())/modules"
            }
        }
        var query: [String : Encodable]? = nil
    }
    
    enum GetAccount: RequestOptions {
        var path: String {
            switch self {
            case .info(let address, _):
                return "/accounts/\(address.toString())"
            case .resource(let address, let type, _):
                return "/accounts/\(address.toString())/resource/\(type)"
            case .module(let address, let name, _):
                return "/accounts/\(address.toString())/module/\(name)"

            }
        }
        
        var query: [String : Encodable]? {
            switch self {
            case .info(_, let ledgerVersion):
                if let version = ledgerVersion {
                    return ["ledger_version": ledgerVersion]
                }
                return nil
            case .resource(_, let type, let ledgerVersion):
                var query: [String: Encodable] = [:]
                if let version = ledgerVersion {
                    query["ledger_version"] = ledgerVersion
                }
                return query
            case .module(_, let name, let ledgerVersion):
                var query: [String: Encodable] = [:]
                if let version = ledgerVersion {
                    query["ledger_version"] = ledgerVersion
                }
                return query
            }
        }
        
        case info(AccountAddress, ledgerVersion: String? = nil)
        case resource(AccountAddress, resourceType: MoveStructTag, ledgerVersion: String? = nil)
        case module(AccountAddress, moduleName: MoveStructTag, ledgerVersion: String? = nil)
    }
}
