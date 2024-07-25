import Foundation
import Types
import Clients
public protocol GerneralAPIProtocol {
    var client: any ClientInterface { get }

    func getLedgerInfo() async throws -> LedgerInfo
    func getChainId() async throws -> UInt8
    func getBlockByVersion(_ ledgerVersion: UInt64) async throws -> Block
    func getBlockByHeight(_ blockHeight: UInt64, withTransactions: Bool) async throws -> Block
    func getTableItem(handle: String, data: TableItemRequest, withLedgerVersion: LedgerVersionArg?) async throws -> Data
}

extension GerneralAPIProtocol {
    public func getLedgerInfo() async throws -> LedgerInfo {
        return try await client.get(path: "").body
    }
    
    public func getChainId() async throws -> UInt8 {
        return try await getLedgerInfo().chainId
    }

    public func getBlockByVersion(_ ledgerVersion: UInt64) async throws -> Block {
        return try await client.get(path: "/blocks/by_version/\(ledgerVersion)").body
    }

    public func getBlockByHeight(_ blockHeight: UInt64, withTransactions: Bool = false) async throws -> Block {
        return try await client.get(path: "/blocks/by_height/\(blockHeight)", query: ["with_transactions": withTransactions]).body
    }
    
    public func getTableItem(handle: String, data: TableItemRequest, withLedgerVersion: LedgerVersionArg? = nil) async throws -> Data {
        var query = [String: AnyNumber]()
        if let version = withLedgerVersion?.ledgerVersion {
            query["ledger_version"] = version
        }
        
        let postRequest = ClientPostRequest(path: "/tables/\(handle)/item", query: query, body: .json(data.json))
        return try await client.send(input: postRequest, serializer: { (input) in 
            return try input.serializer(with: client.converter)
        }, deserializer: { (resp, httpBody) in
            if resp.status.kind == .successful {
                return try await Data(collecting: httpBody ?? [], upTo: .max)
            } else {
                throw try await client.convertBodyToAptosError(httpBody, resp: resp, request: postRequest)
            }
        })
    }
}
