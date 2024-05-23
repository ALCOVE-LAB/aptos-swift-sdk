import Foundation
import Clients
import Types
import HTTPTypes

public protocol AccountAPIProtocol {}

public extension AccountAPIProtocol where Self: AptosCapability {
    func getAccountInfo(
        address: HexInput,
        ledgerVersion: String? = nil) async throws -> AccountData {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountInfo(address: AccountAddress.from(hex.toString()), ledgerVersion: ledgerVersion)
    }
    func getAccountInfo(
        address: AccountAddressInput,
        ledgerVersion: String? = nil) async throws -> AccountData {
            return try await client.get(AccountApiOperation.GetAccount.info(AccountAddress.from(address))).body
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
            AccountApiOperation.GetAccountPage.resources(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion, page: page)
            return try await client.sendPaginateRequest(&request).body
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
        return try await client.get(request).body
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
            AccountApiOperation.GetAccountPage.modules(
                address: try AccountAddress.from(address),
                ledgerVersion: ledgerVersion,
                page: page)
            return try await client.sendPaginateRequest(&request).body
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
        //  TODO: support cache?
        let request: RequestOptions = AccountApiOperation.GetAccount.module(
            try AccountAddress.from(address),
            moduleName: moduleName,
            ledgerVersion: ledgerVersion
        )
        return try await client.get(request).body
    }
    
    
    func getAccountTransactions(address: HexInput, page: Pagination? = nil) async throws -> [TransactionResponse] {
        let hex = try Hex.fromHexInput(address)
        return try await self.getAccountTransactions(
            address: AccountAddress.from(hex.toString()),
            page: page
        )
    }
    func getAccountTransactions(address: AccountAddressInput, page: Pagination? = nil) async throws -> [TransactionResponse] {
        var request: PagenationRequest & RequestOptions =
        AccountApiOperation.GetAccountPage.transactions(
            address: try AccountAddress.from(address), page: page)
        return try await client.sendPaginateRequest(&request).body
    }
}

struct AccountApiOperation {
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
        case resource(AccountAddress, resourceType: MoveStructTag, ledgerVersion: String? = nil)
        case module(AccountAddress, moduleName: MoveStructTag, ledgerVersion: String? = nil)
        
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
