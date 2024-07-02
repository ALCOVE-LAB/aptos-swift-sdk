import Foundation
import Clients
import OpenAPIRuntime
import Types
import Core
import Utils
import BCS
import BigInt
import CryptoSwift

public enum TransactionBuilderdError: Error {
    case invalidFunctionId
    case notFoundEntryFunctionABI(MoveFunctionId)
    case invalidEntryFunction(MoveFunctionId)
    case typeArgumentCountMismatch(expected: Int, received: Int)
    case tooManyArguments(String, Int)
    case tooFewArguments(String, Int)
    case typeMismatch(TypeTag, SimpleEntryFunctionArgumentTypes, Int)
    case missingFeePayerAuthenticator
    case missingAdditionalSignersAuthenticators
    case missingSequenceNumber
}

public typealias FunctionParts = (moduleAddress: String, moduleName: String, functionName: String)
extension MoveFunctionId {
    func getFunctionParts() throws -> FunctionParts {
        let funcNameParts = self.split(separator: ":")
        if funcNameParts.count != 3 {
            throw TransactionBuilderdError.invalidFunctionId
        }
        return (moduleAddress: String(funcNameParts[0]), moduleName: String(funcNameParts[1]), functionName: String(funcNameParts[2]))
    }
}
extension MoveFunction {
    var findFirstNonSignerArg: Int {
       guard let index = params.firstIndex(where: { $0 != "signer" && $0 != "&signer" }) else {
            return params.count
       }
       return index
    }
}
protocol TransactionBuilder: GerneralAPIProtocol, AccountAPIProtocol, TransactionAPIProtocol {
    var client: any ClientInterface { get }
    var aptosConfig: AptosConfig { get }
}

extension TransactionBuilder {
    func generateTransaction(
        args: InputGenerateSingleSignerRawTransactionData
    ) async throws -> SimpleTransaction {
        let payload = try await buildTransactionPayload(
            sender: args.sender,
            data: args.data,
            options: args.options,
            withFeePayer: args.withFeePayer)

        return try await buildRawTransaction(
            args: args,
            payload: payload) 
        }

    func generateTransactionPayload(
        args: InputGenerateMultiAgentRawTransactionData
    ) async throws -> MultiAgentTransaction {
        let payload = try await buildTransactionPayload(
            sender: args.sender,
            data: args.data,
            options: args.options,
            withFeePayer: args.withFeePayer)

        return try await buildRawTransaction(
            args: args,
            payload: payload) 
    }

    func buildTransactionPayload(
        sender: AccountAddressInput,
        data: InputGenerateTransactionPayloadData,
        options: InputGenerateTransactionOptions?,
        withFeePayer: Bool?) async throws  -> TransactionPayload  {

        let generateTransactionPayloadData: InputGenerateTransactionPayloadDataWithRemoteABI

        switch data {
        case is InputScriptData:
            let scriptPayloadData = data as! InputScriptData
            generateTransactionPayloadData = scriptPayloadData
        case is InputMultiSigData:
            let multiSigPayloadData = data as! InputMultiSigData
            let abi = InputMultiSigDataWithRemoteABI(
                multisigAddress: multiSigPayloadData.multisigAddress,
                function: multiSigPayloadData.function,
                typeArguments: multiSigPayloadData.typeArguments,
                functionArguments: multiSigPayloadData.functionArguments,
                abi: multiSigPayloadData.abi)
            generateTransactionPayloadData = abi
        case is InputEntryFunctionData:
            let entryFunctionPayloadData = data as! InputEntryFunctionData
            let abi = InputEntryFunctionDataWithRemoteABI(
                function: entryFunctionPayloadData.function,
                typeArguments: entryFunctionPayloadData.typeArguments,
                functionArguments: entryFunctionPayloadData.functionArguments,
                abi: entryFunctionPayloadData.abi)
            generateTransactionPayloadData = abi
        default:
            fatalError("Invalid data type")
        }
        return try await generateTransactionPayload(args: generateTransactionPayloadData)
    }

    func buildRawTransaction(args: InputGenerateSingleSignerRawTransactionData, payload: TransactionPayload) async throws  -> SimpleTransaction {

        var feePayerAddress: AccountAddressInput?
        if args.withFeePayer == true {
            feePayerAddress = AccountAddress.ZERO.toString()
        }

         return try await buildTransaction(args:
            .init(
                sender: args.sender,
                payload: payload,
                options: args.options,
                feePayerAddress: feePayerAddress
            )
        )
    }

    func buildRawTransaction(args: InputGenerateMultiAgentRawTransactionData, payload: TransactionPayload) async throws  -> MultiAgentTransaction {
        var feePayerAddress: AccountAddressInput?
        if args.withFeePayer == true {
            feePayerAddress = AccountAddress.ZERO.toString()
        }

        return try await buildTransaction(args:
            .init(
                sender: args.sender,
                payload: payload,
                secondarySignerAddresses: args.secondarySignerAddresses,
                options: args.options,
                feePayerAddress: feePayerAddress
            )
        )
    }

    func buildTransaction(args: InputGenerateSingleSignerRawTransactionArgs) async throws -> SimpleTransaction {

        let rawTxn = try await generateRawTransaction(
            sender: args.sender, 
            payload: args.payload, 
            options: args.options,
            feePayerAddress: args.feePayerAddress)

        return SimpleTransaction(rawTransaction: rawTxn, feePayerAddress: args.feePayerAddress != nil ? try AccountAddress.from(args.feePayerAddress!) : nil)
    }

    func buildTransaction(args: InputGenerateMultiAgentRawTransactionArgs) async throws -> MultiAgentTransaction {  

        let rawTxn = try await generateRawTransaction(
            sender: args.sender, 
            payload: args.payload, 
            options: args.options,
            feePayerAddress: args.feePayerAddress)

        let signers = try args.secondarySignerAddresses.map { try AccountAddress.from($0) }

        return MultiAgentTransaction(
            rawTransaction: rawTxn, 
            secondarySignerAddresses: signers, 
            feePayerAddress: args.feePayerAddress != nil ? try AccountAddress.from(args.feePayerAddress!) : nil)
    }

    // script
    func generateTransactionPayload(args: InputScriptData) async throws -> TransactionPayload {
        var functionArguments: [ScriptFunctionArgument] = []
        for arg in args.functionArguments {
            functionArguments.append(arg)
        }
        return try TransactionPayload.script(
            .init(
                bytecode: Hex.fromHexInput(args.bytecode).toUInt8Array(), 
                typeArgs: args.typeArguments ?? [], 
                args: functionArguments
        ));
    }

    func generateTransactionPayload(
        args: InputGenerateTransactionPayloadDataWithRemoteABI
    ) async throws -> TransactionPayload {

        let functionAbi: EntryFunctionABI
        switch args {
            case is InputScriptData:
                return try await generateTransactionPayload(args: args as! InputScriptData)
            case let data  as InputEntryFunctionDataWithRemoteABI:
                let functionParts = try data.function.getFunctionParts()
                functionAbi = try await fetchAbi(
                    key: "entry-function",
                    functionParts: functionParts,
                    abi: data.abi,
                    fetch: fetchEntryFunctionAbi
                )
            case let data  as InputMultiSigDataWithRemoteABI:
                let functionParts = try data.function.getFunctionParts()
                functionAbi = try await fetchAbi(
                    key: "entry-function",
                    functionParts: functionParts,
                    abi: data.abi,
                    fetch: fetchEntryFunctionAbi
                )
            default:
                fatalError("Invalid data type")
        }
        return try await generateTransactionPayloadWithABI(args.withABI(functionAbi))
    }
    
    func generateTransactionPayloadWithABI(_ args: InputGenerateTransactionPayloadDataWithABI) async throws -> TransactionPayload {
        let functionAbi = args.abi
        let functionParts = try args.function.getFunctionParts()
        let typeArguments = try standardizeTypeTags(args.typeArguments)

        if typeArguments.count != functionAbi.typeParameters.count {
            throw TransactionBuilderdError.typeArgumentCountMismatch(expected: functionAbi.typeParameters.count, received: typeArguments.count)
        }

        let functionArguments = try args.functionArguments.enumerated().map { (i, arg) in
            return try convertArgument(
                functionName: args.function, 
                functionAbi: functionAbi, 
                arg: arg,
                position: i, 
                genericTypeParams: typeArguments)
        }

        if functionArguments.count != functionAbi.parameters.count {
            throw TransactionBuilderdError.tooFewArguments(
                "\(functionParts.moduleAddress)::\(functionParts.moduleName)::\(functionParts.functionName)",
                functionAbi.parameters.count)
        }

        let entryFunctionPayload = try TransactionPayload.EntryFunction.build(
            moduleId: "\(functionParts.moduleAddress)::\(functionParts.moduleName)",
            functionName: functionParts.functionName,
            typeArgs: typeArguments,
            args: functionArguments
        )

        if let multiSig =  args as? InputMultiSigDataWithABI {
            let multisigAddress = try AccountAddress.from(multiSig.multisigAddress)
            return TransactionPayload.multiSig(
                .init(
                    multisigAddress: multisigAddress,
                    transactionPayload: .init(transactionPayload: entryFunctionPayload))
                )
        }
        return TransactionPayload.entryFunction(entryFunctionPayload)
    }

    func generateRawTransaction(
        sender: AccountAddressInput, 
        payload: AnyTransactionPayloadInstance, 
        options: InputGenerateTransactionOptions?, 
        feePayerAddress: AccountAddressInput?
    ) async throws -> RawTransaction {

        let getChainId = {  () async throws -> ChainId in 
            if let id =  aptosConfig.network.chainId {
                return .init(id: id)
            }
            return ChainId(id: try await getLedgerInfo().chainId)
        }

        let getGasUnitPrice = {  () async throws -> UInt64 in 
            if let gasUnitPrice = options?.gasUnitPrice {
                return gasUnitPrice
            }
            return try await getGasPriceEstimation().gasEstimate
        }

        let getSequenceNumberForAny = {  () async throws -> UInt64 in 
            if let accountSequenceNumber = options?.accountSequenceNumber {
                return accountSequenceNumber
            }
            let sequence = try await getAccountInfo(address: sender).sequenceNumber
            if let sequenceNumber = UInt64(sequence) {
                return sequenceNumber
            }
            throw TransactionBuilderdError.missingSequenceNumber
        }

        let maxGasAmount = options?.maxGasAmount ?? DEFAULT_MAX_GAS_AMOUNT
        let expireTimestamp: UInt64 = options?.expireTimestamp ?? UInt64(Date().timeIntervalSince1970) + DEFAULT_TXN_EXP_SEC_FROM_NOW

        return .init(
            sender: try AccountAddress.from(sender), 
            sequenceNumber: try await getSequenceNumberForAny(), 
            payload: payload, 
            maxGasAmount: maxGasAmount, 
            gasUnitPrice: try await getGasUnitPrice(), 
            expirationTimestampSecs: expireTimestamp,
            chainId: try await getChainId())
    }
   
    func generateSignedTransaction(
        transaction: AnyRawTransaction,
        senderAuthenticator: AccountAuthenticator,
        feePayerAuthenticator: AccountAuthenticator?,
        additionalSignersAuthenticators: [AccountAuthenticator]?
    ) async throws -> [UInt8] {

        let senderAuthenticator = try AccountAuthenticator.deserialize(
            deserializer: BcsDeserializer(
                input: try senderAuthenticator.bcsToBytes()
            ))
        let txnAuthenticator: TransactionAuthenticator
        if let feePayerAddress = transaction.feePayerAddress {
            if feePayerAuthenticator == nil {
                throw TransactionBuilderdError.missingFeePayerAuthenticator
            }
            txnAuthenticator = .feePayer(.init(
                sender: senderAuthenticator,
                secondarySignerAddresses: (transaction as? MultiAgentTransaction)?.secondarySignerAddresses ?? [],
                secondarySigners: additionalSignersAuthenticators ?? [],
                feePayer: (address: feePayerAddress, authenticator: feePayerAuthenticator!))
            )
        } else if let secondarySignerAddresses = (transaction as? MultiAgentTransaction)?.secondarySignerAddresses {
            if additionalSignersAuthenticators == nil {
                throw TransactionBuilderdError.missingAdditionalSignersAuthenticators
            }
            txnAuthenticator = .multiAgent(.init(
                sender: senderAuthenticator, secondarySignerAddresses: secondarySignerAddresses, secondarySigners: additionalSignersAuthenticators ?? []))
        } else if case let .ed25519(auth) = senderAuthenticator {
            txnAuthenticator = .ed25519(.init(publicKey: auth.publicKey, signature: auth.rawSignature))
        } else {
            txnAuthenticator = .singleSender(.init(sender: senderAuthenticator))
        }
        return try SignedTransaction(rawTransaction: transaction.rawTransaction, authenticator: txnAuthenticator).bcsToBytes()
    }

    
    func fetchEntryFunctionAbi(
        _ functionParts: FunctionParts
    ) async throws -> EntryFunctionABI {
        let functionId = functionParts.moduleAddress + ":" + functionParts.moduleName + ":" + functionParts.functionName
        guard let functionAbi = try await fetchFunctionAbi(fcuntionParts: functionParts) else {
            throw TransactionBuilderdError.notFoundEntryFunctionABI(functionId)
        }

        if !functionAbi.isEntry {
            throw TransactionBuilderdError.invalidEntryFunction(functionId)
        } 

        let numSigners = functionAbi.findFirstNonSignerArg
        var  params: [TypeTag] = [];
        for i in numSigners..<functionAbi.params.count {
            params.append(try TypeTag.parseTypeTag(functionAbi.params[i], allowGenerics: true))
        }

        return .init(signers: numSigners, typeParameters: functionAbi.genericTypeParams, parameters: params)
    }

    func fetchFunctionAbi(
        fcuntionParts: FunctionParts
    ) async throws -> MoveFunction? {
        let module = try await getAccountModule(
            address: fcuntionParts.moduleAddress, 
            moduleName: fcuntionParts.moduleName)
        return module.abi?.exposedFunctions.first(where: { $0.name == fcuntionParts.functionName })
    }

    func fetchAbi<T>(
        key: String,
        functionParts: FunctionParts,
        abi: T?,
        fetch: @escaping (_ parts: FunctionParts) async throws -> T
    ) async throws -> T where T: FunctionABI { 
        if let abi = abi {
            return abi
        }
        let key = "\(key)-\(client.serverURL)-\(functionParts.moduleAddress)-\(functionParts.moduleName)-\(functionParts.functionName)"
        return try await memoizeAsync(
            fetch, 
            key: key,
            ttlMs: 1000 * 60 * 5)(functionParts)
    }

    func standardizeTypeTags(_ typeArguments: [TypeArgument]?) throws -> [TypeTag] {
        return try typeArguments?.map({ (type) in 
            switch type { 
                case .typeTag(let tag):
                    return tag
                case .string(let str):
                    return try TypeTag.parseTypeTag(str)
            }
        }) ?? []
    }
    
    func convertArgument(
        functionName: String,
        functionAbi: FunctionABI,
        arg: AnyFunctionArgumentTypes,
        position: Int,
        genericTypeParams: [TypeTag]
    ) throws -> EntryFunctionArgumentTypes {
        if position >= functionAbi.parameters.count {
            throw TransactionBuilderdError.tooManyArguments(functionName, functionAbi.parameters.count)
        }
        let param = functionAbi.parameters[position]
        return try checkOrConvertArgument(
            arg, 
            param: param, 
            position: position, 
            genericTypeParams: genericTypeParams)
    }

    func checkOrConvertArgument(
        _ arg: AnyFunctionArgumentTypes,
        param: TypeTag,
        position: Int,
        genericTypeParams: [TypeTag]
    ) throws -> EntryFunctionArgumentTypes {
        switch arg {
            case let arg as EntryFunctionArgumentTypes:
                return arg
            case let arg as SimpleEntryFunctionArgumentTypes:
                return try parseArg(arg, param: param, position: position, genericTypeParams: genericTypeParams)
            default:
                fatalError("invaild argument type")
        }
    }

    func parseArg(
        _ arg: SimpleEntryFunctionArgumentTypes,
        param: TypeTag,
        position: Int,
        genericTypeParams: [TypeTag]
    ) throws -> EntryFunctionArgumentTypes {
        switch (param, arg) {
            case (.Bool, let arg as Bool):
                return Boolean(value: arg)
            case (.Address, let arg as String):
                do {
                    return try AccountAddress.fromString(arg)
                } catch {
                    break
                }
            case (.U8, let arg):
                guard let value = arg.toFixedWidthInteger(UInt8.self) else {
                    break
                }
                return U8(value: value)
            case (.U16, let arg):
                guard let value = arg.toFixedWidthInteger(UInt16.self) else {
                    break
                }
                return U16(value: value)
            case (.U32, let arg):
                guard let value = arg.toFixedWidthInteger(UInt32.self) else {
                    break
                }
                return U32(value: value)
            case (.U64, let arg):
                guard let value = arg.toFixedWidthInteger(UInt64.self) else {
                    break
                }
                return U64(value: UInt64(value))
            case (.U128, let arg):
                if let value = arg.toFixedWidthInteger(UInt64.self) {
                    return try U128(value: UInt128(value))
                }
                if let value = arg as? String, let u128 = UInt128(value) {
                    return try U128(value: u128)
                }
                break
            case (.U256, let arg): 
                if let value = arg.toFixedWidthInteger(UInt64.self) {
                    return try U256(value: UInt128(value))
                }
                if let value = arg as? String, let u256 = UInt256(value) {
                    return try U128(value: u256)
                }
                break
            case (.Generic(let genericIndex), _):
                if genericIndex < 0 || genericIndex >= genericTypeParams.count {
                    throw TransactionBuilderdError.typeMismatch(param, arg, position)
                }
                return try checkOrConvertArgument(
                    arg, 
                    param: genericTypeParams[Int(genericIndex)], 
                    position: position, 
                    genericTypeParams: genericTypeParams)
            case (.Vector(.U8), let arg as String):
                return MoveVector<U8>.U8(arg.utf8.map { UInt8($0) })
            case (.Vector(.U8), let arg as [UInt8]):
                return MoveVector<U8>.U8(arg)
            case (.Vector(.U8), let arg as Data):
                return MoveVector<U8>.U8(Array(arg))
            case (.Vector, let arg as [AnyFunctionArgumentTypes]):
                let args = try arg.map { try checkOrConvertArgument(
                    $0, 
                    param: param, 
                    position: position, 
                    genericTypeParams: genericTypeParams) } 
                return MoveVector<EntryFunctionArgumentTypes>(value: args)
            case (.Struct(_), let arg as String) where param.isString():
                return MoveString(value: arg)
            case (.Struct(_), let arg as String) where param.isObject():
                return try AccountAddress.fromString(arg)
            case (.Struct(let structTag), let arg as Optional<AnyFunctionArgumentTypes>) where param.isOption():
                switch arg {
                    case .none:
                        return MoveOption<U8>(value: nil)
                    case .some(let arg):
                        return MoveOption(value: try checkOrConvertArgument(
                            arg, 
                            param: structTag.types[0], 
                            position: position, 
                            genericTypeParams: genericTypeParams))
                }
            default:
                break
        }
        throw TransactionBuilderdError.typeMismatch(param, arg, position)
    }


    func sign(signer: AccountProtocol, transaction: AnyRawTransaction) async throws -> AccountAuthenticator {
        let message = try generateSigningMessage(transaction: transaction)
        return try signer.signWithAuthenticator(message: message)
    }


    func generateSigningMessage(transaction: AnyRawTransaction) throws -> [UInt8] {
        let rawTxn = deriveTransactionType(transaction: transaction)
        var hash = SHA3(variant: .sha256)
        let body: [UInt8]
        if rawTxn is RawTransaction {
            _ = try hash.update(withBytes: RAW_TRANSACTION_SALT.utf8.map { UInt8($0) })
            body = try (rawTxn as! RawTransaction).bcsToBytes()
        } else if rawTxn is MultiAgentRawTransaction {
            _ = try hash.update(withBytes: RAW_TRANSACTION_WITH_DATA_SALT.utf8.map { UInt8($0) })
            body = try (rawTxn as! MultiAgentRawTransaction).bcsToBytes()
        } else if rawTxn is FeePayerRawTransaction {
            _ = try hash.update(withBytes: RAW_TRANSACTION_WITH_DATA_SALT.utf8.map { UInt8($0) })
            body = try (rawTxn as! FeePayerRawTransaction).bcsToBytes()
        } else {
            fatalError("Unknown transaction type to sign on: \(rawTxn)")
        }
        let prefix = try hash.finish()
        return prefix + body
    }
    
    func deriveTransactionType(transaction: AnyRawTransaction) -> AnyRawTransactionInstance {
        if let feePayerAddress = transaction.feePayerAddress {
            return FeePayerRawTransaction(
                rawTxn: transaction.rawTransaction,
                secondarySignerAddresses: (transaction as? MultiAgentTransaction)?.secondarySignerAddresses ?? [],
                feePayerAddress: feePayerAddress)
        }
        if let secondarySignerAddresses = (transaction as? MultiAgentTransaction)?.secondarySignerAddresses {
            return MultiAgentRawTransaction(
                rawTxn: transaction.rawTransaction,
                secondarySignerAddresses: secondarySignerAddresses)
        }
        return transaction.rawTransaction
    }
}
