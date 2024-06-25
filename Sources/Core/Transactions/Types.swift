
import Foundation
import BigInt
import BCS
import Types

public protocol AnyFunctionArgumentTypes {}
public protocol SimpleEntryFunctionArgumentTypes: AnyFunctionArgumentTypes {}
extension Bool: SimpleEntryFunctionArgumentTypes {}
extension Int: SimpleEntryFunctionArgumentTypes {}
extension Float: SimpleEntryFunctionArgumentTypes {}
extension Double: SimpleEntryFunctionArgumentTypes {}
extension UInt8: SimpleEntryFunctionArgumentTypes {}
extension UInt16: SimpleEntryFunctionArgumentTypes {}
extension UInt32: SimpleEntryFunctionArgumentTypes {}
extension UInt64: SimpleEntryFunctionArgumentTypes {}
extension BigUInt: SimpleEntryFunctionArgumentTypes {}
extension String: SimpleEntryFunctionArgumentTypes {}
extension Optional: SimpleEntryFunctionArgumentTypes, AnyFunctionArgumentTypes where Wrapped: AnyFunctionArgumentTypes {}
extension Array: SimpleEntryFunctionArgumentTypes, AnyFunctionArgumentTypes where Element: AnyFunctionArgumentTypes {}
extension Data: SimpleEntryFunctionArgumentTypes {}

public extension SimpleEntryFunctionArgumentTypes {

    func isNumber() -> Bool {
        let arg = self
        return arg is any FixedWidthInteger || arg is any FloatingPoint
    }

    func toFixedWidthInteger<T: FixedWidthInteger>(_ type: T.Type) -> T? {
        guard isNumber() else { return nil }
        let arg = self
        switch arg {
        case let intArg as Int:
            return (intArg >= T.min && intArg <= T.max) ? T(exactly: intArg) : nil
        case let doubleArg as Double:
            return (doubleArg >= Double(T.min) && doubleArg <= Double(T.max)) ? T(exactly: doubleArg) : nil
        case let floatArg as Float:
            return (floatArg >= Float(T.min) && floatArg <= Float(T.max)) ? T(exactly: floatArg) : nil
        case let uint8Arg as UInt8:
            return (uint8Arg >= T.min && uint8Arg <= T.max) ? T(exactly: uint8Arg) : nil
        case let uint16Arg as UInt16:
            return (uint16Arg >= T.min && uint16Arg <= T.max) ? T(exactly: uint16Arg) : nil
        case let uint32Arg as UInt32:
            return (uint32Arg >= T.min && uint32Arg <= T.max) ? T(exactly: uint32Arg) : nil
        case let uint64Arg as UInt64:
            return (uint64Arg >= T.min && uint64Arg <= T.max) ? T(exactly: uint64Arg) : nil
        default:
            return nil
        }
    }
}


public protocol EntryFunctionArgumentTypes: EntryFunctionArgument, AnyFunctionArgumentTypes {}

extension Boolean: EntryFunctionArgumentTypes {}
extension U8: EntryFunctionArgumentTypes {}
extension U16: EntryFunctionArgumentTypes {}
extension U32: EntryFunctionArgumentTypes {}
extension U64: EntryFunctionArgumentTypes {}
extension U128: EntryFunctionArgumentTypes {}
extension U256: EntryFunctionArgumentTypes {}
extension AccountAddress: EntryFunctionArgumentTypes {}
extension MoveVector: EntryFunctionArgumentTypes {}
extension MoveOption: EntryFunctionArgumentTypes {}
extension MoveString: EntryFunctionArgumentTypes {}
extension FixedBytes: EntryFunctionArgumentTypes {}

public protocol ScriptFunctionArgumentTypes: ScriptFunctionArgument {}
extension Boolean: ScriptFunctionArgumentTypes {}
extension U8: ScriptFunctionArgumentTypes {}
extension U16: ScriptFunctionArgumentTypes {}
extension U32: ScriptFunctionArgumentTypes {}
extension U64: ScriptFunctionArgumentTypes {}
extension U128: ScriptFunctionArgumentTypes {}
extension U256: ScriptFunctionArgumentTypes {}
extension AccountAddress: ScriptFunctionArgumentTypes {}
extension MoveVector: ScriptFunctionArgumentTypes where T == U8 {}
extension MoveString: ScriptFunctionArgumentTypes {}
extension FixedBytes: ScriptFunctionArgumentTypes {}


public protocol AnyRawTransactionInstance {}
extension RawTransaction: AnyRawTransactionInstance {}
extension MultiAgentRawTransaction: AnyRawTransactionInstance {}
extension FeePayerRawTransaction: AnyRawTransactionInstance {}


// MARK: - Transaction Generation Types
public struct InputGenerateTransactionOptions {
    public var maxGasAmount: UInt64?
    public var gasUnitPrice: UInt64?
    public var expireTimestamp: UInt64?
    public var accountSequenceNumber: UInt64?
    
    public init(
        maxGasAmount: UInt64? = nil,
        gasUnitPrice: UInt64? = nil,
        expireTimestamp: UInt64? = nil,
        accountSequenceNumber: UInt64? = nil
    ) {
        self.maxGasAmount = maxGasAmount
        self.gasUnitPrice = gasUnitPrice
        self.expireTimestamp = expireTimestamp
        self.accountSequenceNumber = accountSequenceNumber
    }
}


public typealias AnyTransactionPayloadInstance = TransactionPayload
// extension TransactionPayload: AnyTransactionPayloadInstance {}
// extension TransactionPayload.EntryFunction: AnyTransactionPayloadInstance {}
// extension TransactionPayload.Script: AnyTransactionPayloadInstance {}
// extension TransactionPayload.MultiSig: AnyTransactionPayloadInstance {}


public protocol InputGenerateTransactionPayloadData {}
extension InputEntryFunctionData: InputGenerateTransactionPayloadData {}
extension InputScriptData: InputGenerateTransactionPayloadData {}
extension InputMultiSigData: InputGenerateTransactionPayloadData {}


public protocol InputGenerateTransactionPayloadDataWithRemoteABI {
    func withABI(_ abi: EntryFunctionABI) -> InputGenerateTransactionPayloadDataWithABI
}
extension InputScriptData: InputGenerateTransactionPayloadDataWithRemoteABI {
    public func withABI(_ abi: EntryFunctionABI) -> InputGenerateTransactionPayloadDataWithABI {
        fatalError()
    }
}
extension InputEntryFunctionDataWithRemoteABI: InputGenerateTransactionPayloadDataWithRemoteABI {
    public func withABI(_ abi: EntryFunctionABI) -> InputGenerateTransactionPayloadDataWithABI {
        return InputEntryFunctionDataWithABI(
            function: function, 
            typeArguments: typeArguments, 
            functionArguments: functionArguments, 
            abi: abi)
    }
}
extension InputMultiSigDataWithRemoteABI: InputGenerateTransactionPayloadDataWithRemoteABI {
    public func withABI(_ abi: EntryFunctionABI) -> InputGenerateTransactionPayloadDataWithABI {
            return InputMultiSigDataWithABI(
                multisigAddress: multisigAddress,
                function: function, 
                typeArguments: typeArguments, 
                functionArguments: functionArguments, 
                abi: abi)
        }
}


public protocol InputGenerateTransactionPayloadDataWithABI {
    var function: MoveFunctionId { get }
    var typeArguments: [TypeArgument]? { get }
    var functionArguments: [FunctionArgumentTypes] { get }
    var abi: EntryFunctionABI { get }
}
extension InputEntryFunctionDataWithABI: InputGenerateTransactionPayloadDataWithABI {}
extension InputMultiSigDataWithABI: InputGenerateTransactionPayloadDataWithABI {}

public typealias FunctionArgumentTypes = AnyFunctionArgumentTypes

public enum TypeArgument {
    case typeTag(TypeTag)
    case string(String)
}

public struct InputEntryFunctionData {
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI?
    
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI? = nil
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }
}

public struct InputScriptData {
    public var bytecode: HexInput
    public var typeArguments: [TypeTag]?
    public var functionArguments: [ScriptFunctionArgumentTypes]
    
    public init(
        bytecode: HexInput,
        typeArguments: [TypeTag]? = nil,
        functionArguments: [ScriptFunctionArgumentTypes]
    ) {
        self.bytecode = bytecode
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
    }

}

public struct InputMultiSigData {
    public var multisigAddress: AccountAddressInput
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI?
    
    public init(
        multisigAddress: AccountAddressInput,
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI? = nil
    ) {
        self.multisigAddress = multisigAddress
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }
}

public struct InputEntryFunctionDataWithRemoteABI {
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI?
    
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI? = nil
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }
}

public struct InputMultiSigDataWithRemoteABI {
    public var multisigAddress: AccountAddressInput
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI?
    
    public init(
        multisigAddress: AccountAddressInput,
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI? = nil
    ) {
        self.multisigAddress = multisigAddress
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }
}

public struct InputEntryFunctionDataWithABI {
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }

}

public struct InputMultiSigDataWithABI {
    public var multisigAddress: AccountAddressInput
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [FunctionArgumentTypes]
    public var abi: EntryFunctionABI
    
    public init(
        multisigAddress: AccountAddressInput,
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [FunctionArgumentTypes],
        abi: EntryFunctionABI
    ) {
        self.multisigAddress = multisigAddress
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }
}

public struct InputViewFunctionData {
    public var function: MoveFunctionId
    public var typeArguments: [TypeArgument]?
    public var functionArguments: [AnyFunctionArgumentTypes]?
    public var abi: ViewFunctionABI?
    
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeArgument]? = nil,
        functionArguments: [AnyFunctionArgumentTypes]? = nil,
        abi: ViewFunctionABI? = nil
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }

}

public struct InputViewFunctionDataWithRemoteABI {
    public var function: MoveFunctionId
    public var typeArguments: [TypeTag]?
    public var functionArguments: [AnyFunctionArgumentTypes]?
    public var abi: ViewFunctionABI?
    public var aptosConfig: Any
    
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeTag]? = nil,
        functionArguments: [AnyFunctionArgumentTypes]? = nil,
        abi: ViewFunctionABI? = nil,
        aptosConfig: Any
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
        self.aptosConfig = aptosConfig
    }
}

public struct InputViewFunctionDataWithABI {
    public var function: MoveFunctionId
    public var typeArguments: [TypeTag]?
    public var functionArguments: [AnyFunctionArgumentTypes]?
    public var abi: ViewFunctionABI
    
    public init(
        function: MoveFunctionId,
        typeArguments: [TypeTag]? = nil,
        functionArguments: [AnyFunctionArgumentTypes]? = nil,
        abi: ViewFunctionABI
    ) {
        self.function = function
        self.typeArguments = typeArguments
        self.functionArguments = functionArguments
        self.abi = abi
    }

}

public protocol FunctionABI {
    var typeParameters: [MoveFunctionGenericTypeParam] {get}
    var parameters: [TypeTag] {get}
}

public struct ViewFunctionABI: FunctionABI {
    public var typeParameters: [MoveFunctionGenericTypeParam]
    public var parameters: [TypeTag]
    public var returnTypes: [TypeTag]
    
    public init(
        typeParameters: [MoveFunctionGenericTypeParam],
        parameters: [TypeTag],
        returnTypes: [TypeTag]
    ) {
        self.typeParameters = typeParameters
        self.parameters = parameters
        self.returnTypes = returnTypes
    }


}

public struct EntryFunctionABI: FunctionABI {
    public var signers: Int?
    public var typeParameters: [MoveFunctionGenericTypeParam]
    public var parameters: [TypeTag]
    
    public init(
        signers: Int? = nil,
        typeParameters: [MoveFunctionGenericTypeParam],
        parameters: [TypeTag]
    ) {
        self.typeParameters = typeParameters
        self.parameters = parameters
        self.signers = signers
    }
}


public struct InputGenerateSingleSignerRawTransactionArgs {
    public var sender: AccountAddressInput
    public var payload: AnyTransactionPayloadInstance
    public var options: InputGenerateTransactionOptions?
    public var feePayerAddress: AccountAddressInput?
    
    public init(
        sender: AccountAddressInput,
        payload: AnyTransactionPayloadInstance,
        options: InputGenerateTransactionOptions? = nil,
        feePayerAddress: AccountAddressInput? = nil
    ) {
        self.sender = sender
        self.payload = payload
        self.options = options
        self.feePayerAddress = feePayerAddress
    }
}

public struct InputGenerateMultiAgentRawTransactionArgs {
    public var sender: AccountAddressInput
    public var payload: AnyTransactionPayloadInstance
    public var secondarySignerAddresses: [AccountAddressInput]
    public var options: InputGenerateTransactionOptions?
    public var feePayerAddress: AccountAddressInput?
    
    public init(
        sender: AccountAddressInput,
        payload: AnyTransactionPayloadInstance,
        secondarySignerAddresses: [AccountAddressInput],
        options: InputGenerateTransactionOptions? = nil,
        feePayerAddress: AccountAddressInput? = nil
    ) {
        self.sender = sender
        self.payload = payload
        self.secondarySignerAddresses = secondarySignerAddresses
        self.options = options
        self.feePayerAddress = feePayerAddress
    }
}

public protocol InputGenerateRawTransactionArgs {}
extension InputGenerateSingleSignerRawTransactionArgs: InputGenerateRawTransactionArgs {}
extension InputGenerateMultiAgentRawTransactionArgs: InputGenerateRawTransactionArgs {}

public protocol AnyRawTransaction {
    var feePayerAddress: AccountAddress? { set get }
    var rawTransaction: RawTransaction { get }

}
extension SimpleTransaction: AnyRawTransaction {}
extension MultiAgentTransaction: AnyRawTransaction {}

public struct InputSimulateTransactionArgs {
    public var aptosConfig: Any
    public var transaction: AnyRawTransaction
    public var senderPublicKey: AccountAddressInput
    public var secondarySignerPublicKeys: [AccountAddressInput]?
    public var feePayerPublicKey: AccountAddressInput?
    public var options: InputSimulateTransactionOptions?
    
    public init(
        aptosConfig: Any,
        transaction: AnyRawTransaction,
        senderPublicKey: AccountAddressInput,
        secondarySignerPublicKeys: [AccountAddressInput]? = nil,
        feePayerPublicKey: AccountAddressInput? = nil,
        options: InputSimulateTransactionOptions? = nil
    ) {
        self.aptosConfig = aptosConfig
        self.transaction = transaction
        self.senderPublicKey = senderPublicKey
        self.secondarySignerPublicKeys = secondarySignerPublicKeys
        self.feePayerPublicKey = feePayerPublicKey
        self.options = options
    }
}

public struct InputSimulateTransactionOptions {
    public var estimateGasUnitPrice: Bool?
    public var estimateMaxGasAmount: Bool?
    public var estimatePrioritizedGasUnitPrice: Bool?
    
    public init(
        estimateGasUnitPrice: Bool? = nil,
        estimateMaxGasAmount: Bool? = nil,
        estimatePrioritizedGasUnitPrice: Bool? = nil
    ) {
        self.estimateGasUnitPrice = estimateGasUnitPrice
        self.estimateMaxGasAmount = estimateMaxGasAmount
        self.estimatePrioritizedGasUnitPrice = estimatePrioritizedGasUnitPrice
    }
}


public struct InputGenerateSingleSignerRawTransactionData {
    public var sender: AccountAddressInput
    public var data: InputGenerateTransactionPayloadData
    public var options: InputGenerateTransactionOptions?
    public var withFeePayer: Bool?
    
    public init(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) {
        self.sender = sender
        self.data = data
        self.options = options
        self.withFeePayer = withFeePayer
    }
}


public struct InputGenerateMultiAgentRawTransactionData {
    public var sender: AccountAddressInput
    public var data: InputGenerateTransactionPayloadData
    public var secondarySignerAddresses: [AccountAddressInput]
    public var options: InputGenerateTransactionOptions?
    public var withFeePayer: Bool?
    
    public init(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        secondarySignerAddresses: [AccountAddressInput],
        options: InputGenerateTransactionOptions? = nil,
        withFeePayer: Bool? = nil
    ) {
        self.sender = sender
        self.data = data
        self.secondarySignerAddresses = secondarySignerAddresses
        self.options = options
        self.withFeePayer = withFeePayer
    }
}

public protocol InputGenerateTransactionData {
    var withFeePayer: Bool? { get }
}
extension InputGenerateSingleSignerRawTransactionData: InputGenerateTransactionData {}
extension InputGenerateMultiAgentRawTransactionData: InputGenerateTransactionData {}

public struct InputSubmitTransactionData {
    public var transaction: AnyRawTransaction
    public var senderAuthenticator: AccountAuthenticator
    public var feePayerAuthenticator: AccountAuthenticator?
    public var additionalSignersAuthenticators: [AccountAuthenticator]?
    
    public init(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        feePayerAuthenticator: AccountAuthenticator? = nil,
        additionalSignersAuthenticators: [AccountAuthenticator]? = nil
    ) {
        self.transaction = transaction
        self.senderAuthenticator = senderAuthenticator
        self.feePayerAuthenticator = feePayerAuthenticator
        self.additionalSignersAuthenticators = additionalSignersAuthenticators
    }

}