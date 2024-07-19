import Foundation
import Types
import Clients
import Core
import BCS
import OpenAPIRuntime

public protocol GerneralAPIProtocol {
    var client: any ClientInterface { get }

    func getLedgerInfo() async throws -> LedgerInfo
    func getChainId() async throws -> UInt8
    func getBlockByVersion(_ ledgerVersion: UInt64) async throws -> Block
    func getBlockByHeight(_ blockHeight: UInt64, withTransactions: Bool) async throws -> Block
    func getTableItem<T>(handle: String, data: TableItemRequest, withLedgerVersion : LedgerVersionArg) async throws -> T where T: Decodable
}

extension GerneralAPIProtocol {
    public func getLedgerInfo() async throws -> LedgerInfo {
        return try await client.get(path: "").body
    }
    
    public func getChainId() async throws -> UInt8 {
        return try await getLedgerInfo().chainId
    }

    public func getBlockByVersion(_ ledgerVersion: UInt64) async throws -> Block {
        return try await client.get(path: "blocks/by_version/\(ledgerVersion)").body
    }

    public func getBlockByHeight(_ blockHeight: UInt64, withTransactions: Bool = false) async throws -> Block {
        return try await client.get(path: "blocks/by_height/\(blockHeight)", query: ["with_transactions": withTransactions]).body
    }

    public func getTableItem<T>(handle: String, data: TableItemRequest, withLedgerVersion : LedgerVersionArg) async throws -> T where T: Decodable {
        var query = [String: AnyNumber]()
        if let version = withLedgerVersion.ledgerVersion {
            query["ledger_version"] = version
        }
        return try await client.post(path: "tables/\(handle)/item", query: query, bobdy: .json(data.json)).body
    }
}

extension GerneralAPIProtocol where Self: TransactionBuilder {
    func view(payload: InputViewFunctionData, options: LedgerVersionArg? = nil) async throws -> Array<MoveValue>  {
        let viewFunctionPayload = try await generateViewFunctionPayload(payload.remoteABI(with : self.aptosConfig))
        
        let serializer = BcsSerializer()
        try viewFunctionPayload.serialize(serializer: serializer)
        let bytes = serializer.toUInt8Array()

        var query = [String: AnyNumber]()
        if let version = options?.ledgerVersion {
            query["ledger_version"] = version
        }

        let container: OpenAPIRuntime.OpenAPIArrayContainer = try await client.post(path: "/view", query: query, bobdy: .binary(.init(bytes)), contentType: MimeType.bcsViewFunction).body
        return container.value.map({ $0 as? MoveValue }).compactMap({ $0 })
    }
}