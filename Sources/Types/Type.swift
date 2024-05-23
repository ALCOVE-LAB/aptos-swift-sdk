import Foundation
import BCS
@_spi(Generated) import OpenAPIRuntime

public struct ParsingError<T>: Error {
    public let message: String
    public let reason: T
}

public struct ParsingResult<T> {
    public let valid: Bool
    public let invalidReason: T?
    public let invalidReasonMessage: String?
}

extension Serializable {
    public func bcsToBytes() throws -> [UInt8] {
        let serializer = BcsSerializer()
        try serialize(serializer: serializer)
        return serializer.getBytes()
    }
    
    public func bcsToHex() throws -> Hex {
        return Hex(data: try bcsToBytes())
    }
}


// MARK: - Account & Transaction

public struct AccountData: Codable, Hashable, Sendable {
    
    public var sequenceNumber: String
    public var authenticationKey: String
    
    public enum CodingKeys: String, CodingKey {
        case sequenceNumber = "sequence_number"
        case authenticationKey = "authentication_key"
    }
}


public enum ScriptTransactionArgumentVariants: Int {
    case U8 = 0
    case U64 = 1
    case U128 = 2
    case Address = 3
    case U8Vector = 4
    case Bool = 5
    case U16 = 6
    case U32 = 7
    case U256 = 8
}

public struct WaitForTransactionOptions {
    public static let DEFAULT_TXN_TIMEOUT_SEC = 20
    
    public let timeoutSecs: Int?
    public let checkSuccess: Bool?
    public let waitForIndexer: Bool?
}

public typealias MoveStructValue = OpenAPIRuntime.OpenAPIObjectContainer
public typealias MoveStructTag = String
public typealias EntryFunctionId = String
public typealias HexEncodedBytes = String
public typealias IdentifierWrapper = String
public typealias MoveModuleId = String
public typealias MoveType = String

public struct MoveResource: Codable, Hashable, Sendable {
    public var type: MoveStructTag
    public var data: MoveStructValue
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case data
    }
}


public struct MoveModuleBytecode: Codable, Hashable, Sendable {
    public var bytecode: String
    public var abi: MoveModule?
    
    public enum CodingKeys: String, CodingKey {
        case bytecode
        case abi
    }
}

public struct MoveModule: Codable, Hashable, Sendable {
    public var address: String
    
    public var name: String
    
    public var friends: [MoveModuleId]
    
    public var exposedFunctions: [MoveFunction]
    
    public var structs: [MoveStruct]
    
    public enum CodingKeys: String, CodingKey {
        case address
        case name
        case friends
        case exposedFunctions = "exposed_functions"
        case structs
    }
}

public struct MoveFunction: Codable, Hashable, Sendable {
    
    public var name: String
    
    public var visibility: MoveFunctionVisibility
    public var isEntry: Bool
    
    public var isView: Bool
    
    public var genericTypeParams: [MoveFunctionGenericTypeParam]
    public var params: [MoveType]
    
    public var `return`: [MoveType]
    
    public enum CodingKeys: String, CodingKey {
        case name
        case visibility
        case isEntry = "is_entry"
        case isView  = "is_view"
        case genericTypeParams = "generic_type_params"
        case params
        case `return` = "return"
    }
}

public enum MoveFunctionVisibility: String, Codable, Hashable, Sendable {
    case `private` = "private"
    case `public` = "public"
    case friend = "friend"
}

public enum MoveAbility: String, Codable, Hashable, Sendable {
    case store
    case drop
    case key
    case copy
}

public struct MoveFunctionGenericTypeParam: Codable, Hashable, Sendable {
    public var constraints: [MoveAbility]
    
    public enum CodingKeys: String, CodingKey {
        case constraints
    }
}

public struct MoveStructGenericTypeParam: Codable, Hashable, Sendable {
    
    public var constraints: [MoveAbility]
    
    public enum CodingKeys: String, CodingKey {
        case constraints
    }
}

public struct MoveStructField: Codable, Hashable, Sendable {
    
    public var name: String
    public var `type`: MoveType
    
    public enum CodingKeys: String, CodingKey {
        case name
        case type = "type"
    }
}


public enum TransactionResponse: Codable, Sendable {
    
    case blockMetadataTransaction(BlockMetadataTransaction)
    
    case genesisTransaction(GenesisTransaction)
    
    case pendingTransaction(PendingTransaction)
    
    case stateCheckpointTransaction(StateCheckpointTransaction)
    
    case userTransaction(UserTransaction)
    
    case validatorTransaction(ValidatorTransaction)
    
    public var success: Bool {
        switch self {
        case .blockMetadataTransaction(let value):
            value.success
        case .genesisTransaction(let value):
            value.success
        case .pendingTransaction(_):
            false
        case .stateCheckpointTransaction(let value):
            value.success
        case .userTransaction(let value):
            value.success
        case .validatorTransaction(let value):
            value.success
            
        }
    }
    
    
    public var vmStatus: String {
        switch self {
        case .blockMetadataTransaction(let value):
            value.vmStatus
        case .genesisTransaction(let value):
            value.vmStatus
        case .pendingTransaction(_):
            ""
        case .stateCheckpointTransaction(let value):
            value.vmStatus
        case .userTransaction(let value):
            value.vmStatus
        case .validatorTransaction(let value):
            value.vmStatus
            
        }
    }
    
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            String.self,
            forKey: ._type
        )
        
        switch discriminator {
        case "block_metadata_transaction":
            self = .blockMetadataTransaction(try .init(from: decoder))
        case "genesis_transaction":
            self = .genesisTransaction(try .init(from: decoder))
        case "pending_transaction":
            self = .pendingTransaction(try .init(from: decoder))
        case "state_checkpoint_transaction":
            self = .stateCheckpointTransaction(try .init(from: decoder))
        case "user_transaction":
            self = .userTransaction(try .init(from: decoder))
        case "validator_transaction":
            self = .validatorTransaction(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .blockMetadataTransaction(let value):
            try value.encode(to: encoder)
        case .genesisTransaction(let value):
            try value.encode(to: encoder)
        case .pendingTransaction(let value):
            try value.encode(to: encoder)
        case .stateCheckpointTransaction(let value):
            try value.encode(to: encoder)
        case .userTransaction(let value):
            try value.encode(to: encoder)
        case .validatorTransaction(let value):
            try value.encode(to: encoder)
        }
    }
}

public struct BlockMetadataTransaction: Codable, Hashable, Sendable {
    
    public var version: String
    
    public var hash: String
    
    public var stateChangeHash: String
    
    public var eventRootHash: String
    
    public var stateCheckpointHash: String?
    
    public var gasUsed: String
    
    public var success: Bool
    
    public var vmStatus: String
    
    public var accumulatorRootHash: String
    
    public var changes: [WriteSetChange]
    
    public var id: String
    
    public var epoch: String
    
    public var round: String
    
    public var events: [Event]
    
    public var previousBlockVotesBitvec: [Int]
    
    public var proposer: String
    
    public var failedProposerIndices: [Int]
    
    public var timestamp: String
    
    public enum CodingKeys: String, CodingKey {
        case version
        case hash
        case stateChangeHash = "state_change_hash"
        case eventRootHash = "event_root_hash"
        case stateCheckpointHash = "state_checkpoint_hash"
        case gasUsed = "gas_used"
        case success
        case vmStatus = "vm_status"
        case accumulatorRootHash = "accumulator_root_hash"
        case changes
        case id
        case epoch
        case round
        case events
        case previousBlockVotesBitvec = "previousBlockVotesBitvec"
        case proposer
        case failedProposerIndices = "failed_proposer_indices"
        case timestamp
    }
}


public struct GenesisTransaction: Codable, Hashable, Sendable {
    
    public var version: String
    
    public var hash: String
    
    public var stateChangeHash: String
    
    public var eventRootHash: String
    
    public var stateCheckpointHash: String?
    
    public var gasUsed: String
    
    /// Whether the transaction was successful
    public var success: Bool
    
    /// The VM status of the transaction, can tell useful information in a failure
    public var vmStatus: String
    
    public var accumulatorRootHash: String
    
    /// Final state of resources changed by the transaction
    public var changes: [WriteSetChange]
    
    public var payload: GenesisPayload
    
    /// Events emitted during genesis
    public var events: [Event]
    
    public enum CodingKeys: String, CodingKey {
        case version
        case hash
        case stateChangeHash = "state_change_hash"
        case eventRootHash = "event_root_hash"
        case stateCheckpointHash = "state_checkpoint_hash"
        case gasUsed = "gas_used"
        case success
        case vmStatus = "vm_status"
        case accumulatorRootHash = "accumulator_root_hash"
        case changes
        case payload
        case events
    }
}

/// A transaction waiting in mempool
public struct PendingTransaction: Codable, Hashable, Sendable {
    
    public var hash: String
    
    public var sender: String
    
    public var sequenceNumber: String
    
    public var maxGasAmount: String
    
    public var gasUnitPrice: String
    
    public var expirationTimestampSecs: String
    
    public var payload: TransactionPayload
    
    public var signature: TransactionSignature?
    
    public enum CodingKeys: String, CodingKey {
        case hash
        case sender
        case sequenceNumber = "sequence_number"
        case maxGasAmount = "max_gas_amount"
        case gasUnitPrice = "gas_unit_price"
        case expirationTimestampSecs = "expiration_timestamp_secs"
        case payload
        case signature
    }
}

/// A state checkpoint transaction
public struct StateCheckpointTransaction: Codable, Hashable, Sendable {
    public var version: String
    public var hash: String
    public var stateChangeHash: String
    public var eventRootHash: String
    public var stateCheckpointHash: String?
    public var gasUsed: String
    /// Whether the transaction was successful
    public var success: Bool
    /// The VM status of the transaction, can tell useful information in a failure
    public var vmStatus: String
    public var accumulatorRootHash: String
    /// Final state of resources changed by the transaction
    public var changes: [WriteSetChange]
    public var timestamp: String
    
    public enum CodingKeys: String, CodingKey {
        case version
        case hash
        case stateChangeHash = "state_change_hash"
        case eventRootHash = "event_root_hash"
        case stateCheckpointHash = "state_checkpoint_hash"
        case gasUsed = "gas_used"
        case success
        case vmStatus = "vm_status"
        case accumulatorRootHash = "accumulator_root_hash"
        case changes
        case timestamp
    }
}

/// A transaction submitted by a user to change the state of the blockchain
///
/// - Remark: Generated from `#/components/schemas/UserTransaction`.
public struct UserTransaction: Codable, Hashable, Sendable {
    public var version: String
    public var hash: String
    public var stateChangeHash: String
    public var eventRootHash: String
    public var stateCheckpointHash: String?
    public var gasUsed: String
    /// Whether the transaction was successful
    public var success: Bool
    /// The VM status of the transaction, can tell useful information in a failure
    public var vmStatus: String
    public var accumulatorRootHash: String
    /// Final state of resources changed by the transaction
    public var changes: [WriteSetChange]
    
    public var sender: String
    
    public var sequenceNumber: String
    
    public var maxGasAmount: String
    
    public var gasUnitPrice: String
    
    public var expirationTimestampSecs: String
    
    public var payload: TransactionPayload
    
    public var signature: TransactionSignature?
    /// Events generated by the transaction
    public var events: [Event]
    public var timestamp: String
    
    public enum CodingKeys: String, CodingKey {
        case version
        case hash
        case stateChangeHash = "state_change_hash"
        case eventRootHash = "event_root_hash"
        case stateCheckpointHash = "state_checkpoint_hash"
        case gasUsed = "gas_used"
        case success
        case vmStatus = "vm_status"
        case accumulatorRootHash = "accumulator_root_hash"
        case changes
        case sender
        case sequenceNumber = "sequence_number"
        case maxGasAmount = "max_gas_amount"
        case gasUnitPrice = "gas_unit_price"
        case expirationTimestampSecs = "expiration_timestamp_secs"
        case payload
        case signature
        case events
        case timestamp
    }
}

public struct ValidatorTransaction: Codable, Hashable, Sendable {
    public var version: String
    public var hash: String
    public var stateChangeHash: String
    public var eventRootHash: String
    public var stateCheckpointHash: String?
    public var gasUsed: String
    /// Whether the transaction was successful
    public var success: Bool
    /// The VM status of the transaction, can tell useful information in a failure
    public var vmStatus: String
    public var accumulatorRootHash: String
    /// Final state of resources changed by the transaction
    public var changes: [WriteSetChange]
    public var events: [Event]
    public var timestamp: String
    
    public enum CodingKeys: String, CodingKey {
        case version
        case hash
        case stateChangeHash = "state_change_hash"
        case eventRootHash = "event_root_hash"
        case stateCheckpointHash = "state_checkpoint_hash"
        case gasUsed = "gas_used"
        case success
        case vmStatus = "vm_status"
        case accumulatorRootHash = "accumulator_root_hash"
        case changes
        case events
        case timestamp
    }
}

public enum WriteSetChange: Codable, Hashable, Sendable {
    case deleteModule(DeleteModule)
    case deleteResource(DeleteResource)
    case deleteTableItem(DeleteTableItem)
    case writeModule(WriteModule)
    case writeResource(WriteResource)
    case writeTableItem(WriteTableItem)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            String.self,
            forKey: ._type
        )
        switch discriminator {
        case "delete_module":
            self = .deleteModule(try .init(from: decoder))
        case "delete_resource":
            self = .deleteResource(try .init(from: decoder))
        case "delete_table_item":
            self = .deleteTableItem(try .init(from: decoder))
        case "write_module":
            self = .writeModule(try .init(from: decoder))
        case "write_resource":
            self = .writeResource(try .init(from: decoder))
        case "write_table_item":
            self = .writeTableItem(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .deleteModule(let value):
            try value.encode(to: encoder)
        case .deleteResource(let value):
            try value.encode(to: encoder)
        case .deleteTableItem(let value):
            try value.encode(to: encoder)
        case .writeModule(let value):
            try value.encode(to: encoder)
        case .writeResource(let value):
            try value.encode(to: encoder)
        case .writeTableItem(let value):
            try value.encode(to: encoder)
        }
    }
}


public struct Event: Codable, Hashable, Sendable {
    public typealias Data = OpenAPIRuntime.OpenAPIValueContainer
    
    public var guid: EventGuid
    public var sequenceNumber: String
    public var type: MoveType
    public var data: Event.Data
    
    public enum CodingKeys: String, CodingKey {
        case guid
        case sequenceNumber = "sequence_number"
        case type
        case data
    }
}

public struct EventGuid: Codable, Hashable, Sendable {
    public var creationNumber: String
    public var accountAddress: String
    
    public enum CodingKeys: String, CodingKey {
        case creationNumber = "creation_number"
        case accountAddress = "account_address"
    }
}

public struct DeleteModule: Codable, Hashable, Sendable {
    public var address: String
    /// State key hash
    public var stateKeyHash: String
    public var module: MoveModuleId
    
    public enum CodingKeys: String, CodingKey {
        case address
        case stateKeyHash = "state_key_hash"
        case module
    }
}

public struct DeleteResource: Codable, Hashable, Sendable {
    public var address: String
    /// State key hash
    public var stateKeyHash: String
    public var resource: MoveStructTag
    
    public enum CodingKeys: String, CodingKey {
        case address
        case stateKeyHash = "state_key_hash"
        case resource
    }
}

/// Delete a table item
public struct DeleteTableItem: Codable, Hashable, Sendable {
    public var stateKeyHash: String
    
    public var handle: HexEncodedBytes
    
    public var key: HexEncodedBytes
    
    public var data: DeletedTableData?
    
    public enum CodingKeys: String, CodingKey {
        case stateKeyHash = "state_key_hash"
        case handle
        case key
        case data
    }
}

/// Deleted table data
public struct DeletedTableData: Codable, Hashable, Sendable {
    public typealias Key = OpenAPIRuntime.OpenAPIValueContainer
    
    public var key: Key
    
    public var keyType: String
    
    public enum CodingKeys: String, CodingKey {
        case key
        case keyType = "key_type"
    }
}

public struct WriteModule: Codable, Hashable, Sendable {
    public var address: String
    /// State key hash
    public var stateKeyHash: String
    
    public var data: MoveModuleBytecode
    
    public enum CodingKeys: String, CodingKey {
        case address
        case stateKeyHash = "state_key_hash"
        case data
    }
}
/// Write a resource or update an existing one
public struct WriteResource: Codable, Hashable, Sendable {
    public var address: String
    /// State key hash
    public var stateKeyHash: String
    public var data: MoveResource
    
    public enum CodingKeys: String, CodingKey {
        case address
        case stateKeyHash = "state_key_hash"
        case data
    }
}

public struct WriteTableItem: Codable, Hashable, Sendable {
    
    public var stateKeyHash: String
    
    public var handle: HexEncodedBytes
    
    public var key: HexEncodedBytes
    
    public var value: HexEncodedBytes
    
    public var data: DecodedTableData?
    
    public enum CodingKeys: String, CodingKey {
        case stateKeyHash = "state_key_hash"
        case handle
        case key
        case value
        case data
    }
}

public struct DecodedTableData: Codable, Hashable, Sendable {
    public typealias Key = OpenAPIRuntime.OpenAPIValueContainer
    public typealias Value = OpenAPIRuntime.OpenAPIValueContainer
    
    /// Key of table in JSON
    public var key: Key
    /// Type of key
    public var keyType: String
    /// Value of table in JSON
    public var value: Value
    /// Type of value
    public var valueType: String
    
    public enum CodingKeys: String, CodingKey {
        case key
        case keyType = "key_type"
        case value
        case valueType = "value_type"
    }
}

public enum GenesisPayload: Codable, Hashable, Sendable {
    
    case writeSetPayload(WriteSetPayload)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            String.self,
            forKey: ._type
        )
        switch discriminator {
        case "write_set_payload":
            self = .writeSetPayload(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .writeSetPayload(value):
            try value.encode(to: encoder)
        }
    }
}

/// A writeset payload, used only for genesis
public struct WriteSetPayload: Codable, Hashable, Sendable {
    
    public var writeSet: WriteSet
    
    public enum CodingKeys: String, CodingKey {
        case writeSet = "write_set"
    }
}

public enum WriteSet: Codable, Hashable, Sendable {
    case directWriteSet(DirectWriteSet)
    case scriptWriteSet(ScriptWriteSet)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            String.self,
            forKey: ._type
        )
        switch discriminator {
        case "direct_write_set":
            self = .directWriteSet(try .init(from: decoder))
        case "script_write_set":
            self = .scriptWriteSet(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .directWriteSet(value):
            try value.encode(to: encoder)
        case let .scriptWriteSet(value):
            try value.encode(to: encoder)
        }
    }
}

public struct DirectWriteSet: Codable, Hashable, Sendable {
    
    public var changes: [WriteSetChange]
    
    public var events: [Event]
    
    public enum CodingKeys: String, CodingKey {
        case changes
        case events
    }
}

public struct ScriptWriteSet: Codable, Hashable, Sendable {
    public var executeAs: String
    public var script: ScriptPayload
    
    public enum CodingKeys: String, CodingKey {
        case executeAs = "execute_as"
        case script
    }
}

/// Payload which runs a script that can run multiple functions
public struct ScriptPayload: Codable, Hashable, Sendable {
    public typealias Argument = OpenAPIRuntime.OpenAPIValueContainer
    public var code: MoveScriptBytecode
    /// Type arguments of the function
    public var typeArguments: [MoveType]
    /// Arguments of the function
    public var arguments: [ScriptPayload.Argument]
    
    public enum CodingKeys: String, CodingKey {
        case code
        case typeArguments = "type_arguments"
        case arguments
    }
}

/// Move script bytecode
public struct MoveScriptBytecode: Codable, Hashable, Sendable {
    public var bytecode: HexEncodedBytes
    public var abi: MoveFunction?
    
    public enum CodingKeys: String, CodingKey {
        case bytecode
        case abi
    }
}

/// A move struct
public struct MoveStruct: Codable, Hashable, Sendable {
    
    public var name: IdentifierWrapper
    /// Whether the struct is a native struct of Move
    public var isNative: Bool
    
    /// Abilities associated with the struct
    public var abilities: [MoveAbility]
    /// Generic types associated with the struct
    public var genericTypeParams: [MoveStructGenericTypeParam]
    /// Fields associated with the struct
    public var fields: [MoveStructField]
    
    public enum CodingKeys: String, CodingKey {
        case name
        case isNative = "is_native"
        case abilities
        case genericTypeParams = "generic_type_params"
        case fields
    }
}

/// An enum of the possible transaction payloads
public enum TransactionPayload: Codable, Hashable, Sendable {
    public typealias DeprecatedModuleBundlePayload = OpenAPIRuntime.OpenAPIObjectContainer
    
    case entryFunctionPayload(EntryFunctionPayload)
    
    case moduleBundlePayload(TransactionPayload.DeprecatedModuleBundlePayload)
    
    case multisigPayload(MultisigPayload)
    
    case scriptPayload(ScriptPayload)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            Swift.String.self,
            forKey: ._type
        )
        switch discriminator {
        case "entry_function_payload":
            self = .entryFunctionPayload(try .init(from: decoder))
        case "module_bundle_payload":
            self = .moduleBundlePayload(try .init(from: decoder))
        case "multisig_payload":
            self = .multisigPayload(try .init(from: decoder))
        case "script_payload":
            self = .scriptPayload(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .entryFunctionPayload(value):
            try value.encode(to: encoder)
        case let .moduleBundlePayload(value):
            try value.encode(to: encoder)
        case let .multisigPayload(value):
            try value.encode(to: encoder)
        case let .scriptPayload(value):
            try value.encode(to: encoder)
        }
    }
}

/// Payload which runs a single entry function
public struct EntryFunctionPayload: Codable, Hashable, Sendable {
    public typealias Argument = OpenAPIRuntime.OpenAPIValueContainer
    public var function: EntryFunctionId
    /// Type arguments of the function
    public var typeArguments: [MoveType]
    /// Arguments of the function
    public var arguments: [EntryFunctionPayload.Argument]
    
    public enum CodingKeys: String, CodingKey {
        case function
        case typeArguments
        case arguments
    }
}

/// A multisig transaction that allows an owner of a multisig account to execute a pre-approved
/// transaction as the multisig account.
public struct MultisigPayload: Codable, Hashable, Sendable {
    
    public var multisigAddress: String
    
    public var transactionPayload: MultisigTransactionPayload?
    
    public enum CodingKeys: String, CodingKey {
        case multisigAddress = "multisig_address"
        case transactionPayload = "transaction_payload"
    }
}

public enum MultisigTransactionPayload: Codable, Hashable, Sendable {
    case entryFunctionPayload(EntryFunctionPayload)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            Swift.String.self,
            forKey: ._type
        )
        switch discriminator {
        case "entry_function_payload":
            self = .entryFunctionPayload(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .entryFunctionPayload(value):
            try value.encode(to: encoder)
        }
    }
}

public enum TransactionSignature: Codable, Hashable, Sendable {
    case ed25519(Ed25519Signature)
    case feePayer(FeePayerSignature)
    case multiAgent(MultiAgentSignature)
    case multiEd25519(MultiEd25519Signature)
    case singleSender(AccountSignature)
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            Swift.String.self,
            forKey: ._type
        )
        switch discriminator {
        case "ed25519_signature":
            self = .ed25519(try .init(from: decoder))
        case "fee_payer_signature":
            self = .feePayer(try .init(from: decoder))
        case "multi_agent_signature":
            self = .multiAgent(try .init(from: decoder))
        case "multi_ed25519_signature":
            self = .multiEd25519(try .init(from: decoder))
        case "single_sender":
            self = .singleSender(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .ed25519(value):
            try value.encode(to: encoder)
        case let .feePayer(value):
            try value.encode(to: encoder)
        case let .multiAgent(value):
            try value.encode(to: encoder)
        case let .multiEd25519(value):
            try value.encode(to: encoder)
        case let .singleSender(value):
            try value.encode(to: encoder)
        }
    }
}

/// A single Ed25519 signature
public struct Ed25519Signature: Codable, Hashable, Sendable {
    
    public var publicKey: HexEncodedBytes
    
    public var signature: HexEncodedBytes
    
    public enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case signature
    }
}

/// Fee payer signature for fee payer transactions
///
/// This allows you to have transactions across multiple accounts and with a fee payer
public struct FeePayerSignature: Codable, Hashable, Sendable {
    
    public var sender: AccountSignature
    /// The other involved parties' addresses
    public var secondarySignerAddresses: [String]
    /// The associated signatures, in the same order as the secondary addresses
    public var secondarySigners: [AccountSignature]
    
    public var feePayerAddress: String
    
    public var feePayerSigner: AccountSignature
    
    public enum CodingKeys: String, CodingKey {
        case sender
        case secondarySignerAddresses = "secondary_signer_addresses"
        case secondarySigners = "secondary_signers"
        case feePayerAddress = "fee_payer_address"
        case feePayerSigner = "fee_payer_signer"
    }
}

/// Multi agent signature for multi agent transactions
///
/// This allows you to have transactions across multiple accounts
public struct MultiAgentSignature: Codable, Hashable, Sendable {
    public var sender: AccountSignature
    /// The other involved parties' addresses
    public var secondarySignerAddresses: [String]
    /// The associated signatures, in the same order as the secondary addresses
    ///
    /// - Remark: Generated from `#/components/schemas/MultiAgentSignature/secondary_signers`.
    public var secondarySigners: [AccountSignature]
    
    public enum CodingKeys: String, CodingKey {
        case sender
        case secondarySignerAddresses = "secondary_signer_addresses"
        case secondarySigners = "secondary_signers"
    }
}

/// Account signature scheme
///
/// The account signature scheme allows you to have two types of accounts:
///
/// 1. A single Ed25519 key account, one private key
/// 2. A k-of-n multi-Ed25519 key account, multiple private keys, such that k-of-n must sign a transaction.
/// 3. A single Secp256k1Ecdsa key account, one private key
public enum AccountSignature: Codable, Hashable, Sendable {
    case ed25519(Ed25519Signature)
    case multiEd25519(MultiEd25519Signature)
    case multiKey(MultiKeySignature)
    case singleKey(SingleKeySignature)
    
    public enum CodingKeys: String, CodingKey {
        case _type = "type"
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(
            Swift.String.self,
            forKey: ._type
        )
        switch discriminator {
        case "ed25519_signature":
            self = .ed25519(try .init(from: decoder))
        case "multi_ed25519_signature":
            self = .multiEd25519(try .init(from: decoder))
        case "multi_key_signature":
            self = .multiKey(try .init(from: decoder))
        case "single_key_signature":
            self = .singleKey(try .init(from: decoder))
        default:
            throw DecodingError.unknownOneOfDiscriminator(
                discriminatorKey: CodingKeys._type,
                discriminatorValue: discriminator,
                codingPath: decoder.codingPath
            )
        }
    }
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .ed25519(value):
            try value.encode(to: encoder)
        case let .multiEd25519(value):
            try value.encode(to: encoder)
        case let .multiKey(value):
            try value.encode(to: encoder)
        case let .singleKey(value):
            try value.encode(to: encoder)
        }
    }
}

/// A Ed25519 multi-sig signature
///
/// This allows k-of-n signing for a transaction
public struct MultiEd25519Signature: Codable, Hashable, Sendable {
    /// The public keys for the Ed25519 signature
    public var publicKeys: [HexEncodedBytes]
    /// Signature associated with the public keys in the same order
    public var signatures: [HexEncodedBytes]
    /// The number of signatures required for a successful transaction
    public var threshold: Int
    public var bitmap: HexEncodedBytes
    
    public enum CodingKeys: String, CodingKey {
        case publicKeys = "public_keys"
        case signatures
        case threshold
        case bitmap
    }
}

/// A multi key signature
public struct MultiKeySignature: Codable, Hashable, Sendable {
    public var signatures: [IndexedSignature]
    public var signaturesRequired: Int
    
    public enum CodingKeys: String, CodingKey {
        case signatures
        case signaturesRequired = "signatures_required"
    }
}

/// A single key signature
public struct SingleKeySignature: Codable, Hashable, Sendable {
    
    public var publicKey: HexEncodedBytes
    public var signature: HexEncodedBytes
    
    public enum CodingKeys: String, CodingKey {
        case publicKey = "public_key"
        case signature
    }
}

public struct IndexedSignature: Codable, Hashable, Sendable {
    public var index: Int
    public enum CodingKeys: String, CodingKey {
        case index
    }
}

/// Struct holding the outputs of the estimate gas API
public struct GasEstimation: Codable, Hashable, Sendable {
    /// The deprioritized estimate for the gas unit price
    public var deprioritizedGasEstimate: Int?
    /// The current estimate for the gas unit price
    public var gasEstimate: Int
    /// The prioritized estimate for the gas unit price
    public var prioritizedGasEstimate: Int?
    
    public enum CodingKeys: String, CodingKey {
        case deprioritizedGasEstimate = "deprioritized_gas_estimate"
        case gasEstimate = "gas_estimate"
        case prioritizedGasEstimate = "prioritized_gas_estimate"
    }
}
