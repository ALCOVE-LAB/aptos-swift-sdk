import OpenAPIURLSession

public class AccountClient {
    public init() {}
    
    public func getAccount() async throws -> Any  {
        let client = Client(serverURL: try Servers.server1(), transport: URLSessionTransport())
        try await client.get_transaction_by_hash(path: .init(txn_hash: ""))
        let resp = try await client.get_account(.init(path: .init(address: "adress")))
        return resp
    }
    
    public func getTransactionByHash() async throws -> PendingTransactionResponse {
        let client = Client(serverURL: try Servers.server1(), transport: URLSessionTransport())
        let resp = try await client.get_transaction_by_hash(path: .init(txn_hash: ""))
        switch resp {
        case .ok(let ok):
            if case .pending_transaction(let trans) = try ok.body.json {
                return trans
            }
        default:
            break
        }
        fatalError()
    }
}


extension Components.Schemas.Transaction_PendingTransaction : PendingTransactionResponse {
    public var hash: String {
        return value2.hash
    }
    
    public var sender: String {
        return value2.sender
    }
    
    public var type: String {
        return value1._type
    }
    public var sequenceNumber: String {
        return value2.sequence_number
    }
    
    public var maxGasAmount: String {
        return value2.max_gas_amount
    }
    
    public var gasUnitPrice: String {
        return value2.gas_unit_price
    }
    
    public var expirationTimestampSecs: String {
        return value2.expiration_timestamp_secs
    }
}


enum TransactionResponse {
    case pending(PendingTransactionResponse)
//    case user(UserTransactionResponse)
//    case genesis(GenesisTransactionResponse)
//    case blockMetadata(BlockMetadataTransactionResponse)
//    case stateCheckpoint(StateCheckpointTransactionResponse)
}
public protocol PendingTransactionResponse {
    var hash: String { get }
    var sender: String { get }
    var sequenceNumber: String { get }
    var maxGasAmount: String { get }
    var gasUnitPrice: String { get }
    var expirationTimestampSecs: String { get }
//    var payload: TransactionPayload { get }
//    var signature: TransactionSignature?
}

/*

struct UserTransactionResponse {
    var type: String
    var version: String
    var hash: String
    var stateChangeHash: String
    var eventRootHash: String
    var stateCheckpointHash: String?
    var gasUsed: String
    var success: Bool
    var vmStatus: String
    var accumulatorRootHash: String
    var changes: [WriteSetChange]
    var sender: String
    var sequenceNumber: String
    var maxGasAmount: String
    var gasUnitPrice: String
    var expirationTimestampSecs: String
    var payload: TransactionPayload
    var signature: TransactionSignature?
    var events: [Event]
    var timestamp: String
}

struct GenesisTransactionResponse {
    var type: String
    var version: String
    var hash: String
    var stateChangeHash: String
    var eventRootHash: String
    var stateCheckpointHash: String?
    var gasUsed: String
    var success: Bool
    var vmStatus: String
    var accumulatorRootHash: String
    var changes: [WriteSetChange]
    var payload: GenesisPayload
    var events: [Event]
}

struct BlockMetadataTransactionResponse {
    var type: String
    var version: String
    var hash: String
    var stateChangeHash: String
    var eventRootHash: String
    var stateCheckpointHash: String?
    var gasUsed: String
    var success: Bool
    var vmStatus: String
    var accumulatorRootHash: String
    var changes: [WriteSetChange]
    var id: String
    var epoch: String
    var round: String
    var events: [Event]
    var previousBlockVotesBitvec: [Int]
    var proposer: String
    var failedProposerIndices: [Int]
    var timestamp: String
}

struct StateCheckpointTransactionResponse {
    var type: String
    var version: String
    var hash: String
    var stateChangeHash: String
    var eventRootHash: String
    var stateCheckpointHash: String?
    var gasUsed: String
    var success: Bool
    var vmStatus: String
    var accumulatorRootHash: String
    var changes: [WriteSetChange]
    var timestamp: String
}
*/
