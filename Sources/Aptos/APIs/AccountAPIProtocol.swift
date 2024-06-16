import Foundation
import Clients
import Types
import HTTPTypes
import Core
import Utils
public protocol AccountAPIProtocol {
    var client: any ClientInterface { get }
}

public extension AccountAPIProtocol {
    // TODO: ledgerVersion as Types.LedgerVersionArg
   
    func getAccountInfo(
        address: AccountAddressInput,
        ledgerVersion: String? = nil) async throws -> AccountData {
            return try await client.get(AccountApiOperation.GetAccount.info(AccountAddress.from(address), ledgerVersion: ledgerVersion)).body
    }
    
    func getAccountResources(
        address: AccountAddressInput,
        ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveResource] {
            var request: PagenationRequest & RequestOptions = 
            AccountApiOperation.GetAccountPage.resources(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion, page: page)
            return try await client.sendPaginateRequest(&request).body
    }
    
    func getAccountResource(
        address: AccountAddressInput,
        resourceType: MoveStructId,
        ledgerVersion: String? = nil
    ) async throws -> MoveStructValue {
        let request: RequestOptions = AccountApiOperation.GetAccount.resource(
            try AccountAddress.from(address),
            resourceType: resourceType,
            ledgerVersion: ledgerVersion
        )
        let resource: MoveResource = try await client.get(request).body
        return resource.data
    }
    
    func getAccountResource<Value: Codable & Sendable>(
        address: AccountAddressInput,
        resourceType: MoveStructId,
        ledgerVersion: String? = nil
    ) async throws -> Value {
        let request: RequestOptions = AccountApiOperation.GetAccount.resource(
            try AccountAddress.from(address),
            resourceType: resourceType,
            ledgerVersion: ledgerVersion
        )
        let resource: MoveResourceParser<Value> = try await client.get(request).body
        return resource.data
    }
    
    func getAccountModules(
        address: AccountAddressInput,
        ledgerVersion: String? = nil,
        page: Pagination? = nil) async throws -> [MoveModuleBytecode] {
            var request: PagenationRequest & RequestOptions =
            AccountApiOperation.GetAccountPage.modules(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion,
                page: page)
            return try await client.sendPaginateRequest(&request).body
    }
    
    func getAccountModule(
        address: AccountAddressInput,
        moduleName: String,
        ledgerVersion: String? = nil
    ) async throws -> MoveModuleBytecode {

        let request: RequestOptions = AccountApiOperation.GetAccount.module(
            try AccountAddress.from(address),
            moduleName: moduleName,
            ledgerVersion: ledgerVersion
        )
        if ledgerVersion == nil {
            return try await client.get(request).body
        }
        return try await memoizeAsync(
            client.get,
            key: "module-\(address)-\(moduleName)",
            ttlMs: 1000 * 60 * 5)(request).body
    }
    
    func getAccountTransactions(address: AccountAddressInput, page: Pagination? = nil) async throws -> [TransactionResponse] {
        var request: PagenationRequest & RequestOptions =
        AccountApiOperation.GetAccountPage.transactions(
            address: try AccountAddress.from(address), page: page)
        return try await client.sendPaginateRequest(&request).body
    }
}

private struct AccountApiOperation {
    struct GetAccountPage: RequestOptions, PagenationRequest {
        
        enum ModuleType {
            case reouseces
            case modules
            case transactions
        }
        
        static func resources(
            address: AccountAddress,
            ledgerVersion: String? = nil,
            page: Pagination? = nil) -> GetAccountPage {
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
            page: Pagination? = nil) -> GetAccountPage {
            return self.init(
                moduleType: .modules,
                address: address,
                ledgerVersion: ledgerVersion,
                page: page
            )
        }
        
        static func transactions(
            address: AccountAddress,
            page: Pagination?) -> GetAccountPage {
                return self.init(
                    moduleType: .transactions,
                    address: address,
                    ledgerVersion: nil,
                    page: page
                )
            }

        let address: AccountAddress
        let ledgerVersion: String?
        let page: Pagination?
        let moduleType: ModuleType

        var path: String {
            switch moduleType {
            case .reouseces:
                return "/accounts/\(address.toString())/resources"
            case .modules:
                return "/accounts/\(address.toString())/modules"
            case .transactions:
                return "/accounts/\(address.toString())/transactions"
            }
        }
        var query: Parameter?
        
        private init(
            moduleType: ModuleType,
            address: AccountAddress,
            ledgerVersion: String? = nil,
            page: Pagination? = nil
        ) {
            self.moduleType = moduleType
            self.address = address
            self.ledgerVersion = ledgerVersion
            self.page = page
            
            var query: [String: Encodable] = [:]
            if let version = ledgerVersion {
                query["ledger_version"] = version
            }
            if let page = page {
                query["start"] = page.offset
                query["limit"] = page.limit
            }
            self.query = query
        }
        
    }
    
    enum GetAccount: RequestOptions {
        
        case info(AccountAddress, ledgerVersion: String? = nil)
        case resource(AccountAddress, resourceType: MoveStructId, ledgerVersion: String? = nil)
        case module(AccountAddress, moduleName: MoveStructId, ledgerVersion: String? = nil)
        
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
            case .info(_, let ledgerVersion),
                    .resource(_, _, let ledgerVersion),
                    .module(_, _, let ledgerVersion):
                var query: [String: Encodable] = [:]
                if let version = ledgerVersion {
                    query["ledger_version"] = version
                }
                return query
            }
        }
    }
}
