

import Foundation
import BCS
import Types
import Core

public enum TransactionPayloadError: Error {
    case invalidVariantIndex
}

public enum TransactionPayload: Serializable, Deserializable {
    case entryFunction(EntryFunction)
    case script(Script)
    case multiSig(MultiSig)

    var variant: TransactionPayloadVariants {
        switch self {
            case .script:
                return .script
            case .entryFunction:
                return .entryFunction
            case .multiSig:
                return .multiSig
        }
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: variant.rawValue)
        switch self {
            case .script(let script):
                try script.serialize(serializer: serializer)
            case .entryFunction(let entryFunction):
                try entryFunction.serialize(serializer: serializer)
            case .multiSig(let multiSig):
                try multiSig.serialize(serializer: serializer)
        }        
    }

    public static func deserialize(deserializer: Deserializer) throws -> TransactionPayload {
        let index = try deserializer.deserializeVariantIndex()
        guard let variant = TransactionPayloadVariants(rawValue: index) else {
            throw TransactionPayloadError.invalidVariantIndex
        }
        switch variant {
             case .entryFunction:
                return .entryFunction(try EntryFunction.deserialize(deserializer: deserializer))
            case .script:
                return .script(try Script.deserialize(deserializer: deserializer))
            case .multiSig:
                return .multiSig(try MultiSig.deserialize(deserializer: deserializer))
        }
    }
}

extension TransactionPayload {
    public struct EntryFunction: Serializable, Deserializable {
        public let moduleName: ModuleId
        public let functionName: Identifier
        public let typeArgs: [TypeTag]
        public let args: [EntryFunctionArgument]

        
        public init(moduleName: ModuleId, functionName: Identifier, typeArgs: [TypeTag], args: [EntryFunctionArgument]) {
            self.moduleName = moduleName
            self.functionName = functionName
            self.typeArgs = typeArgs
            self.args = args
        }

        public func serialize(serializer: Serializer) throws {
            try moduleName.serialize(serializer: serializer)
            try functionName.serialize(serializer: serializer)
            try serializer.serializeVector(values: typeArgs)
            try serializer.serializeVariantIndex(value: UInt32(args.count))
            for arg in args {
                try arg.serializeForEntryFunction(serializer: serializer)
            }
        }

        public static func deserialize(deserializer: Deserializer) throws -> EntryFunction {
            let moduleName = try ModuleId.deserialize(deserializer: deserializer)
            let functionName = try Identifier.deserialize(deserializer: deserializer)
            let typeArgs = try deserializer.deserializeVector(TypeTag.self)
            let length = try deserializer.deserializeVariantIndex()
            var args = [EntryFunctionArgument]()
            for _ in 0..<length {
                let fixedBytesLength = try deserializer.deserializeVariantIndex()
                args.append(try EntryFunctionBytes.deserialize(deserializer: deserializer, length: Int(fixedBytesLength)))
            }
            return .init(moduleName: moduleName, functionName: functionName, typeArgs: typeArgs, args: args)
        }

        public static func build(moduleId: MoveModuleId, functionName: String, typeArgs: [TypeTag], args: [EntryFunctionArgument]) throws -> EntryFunction {
            let moduleId = try  ModuleId.fromStr(moduleId)
            return .init(moduleName: moduleId, functionName: Identifier(functionName), typeArgs: typeArgs, args: args)
        }
        
    }
}

extension TransactionPayload {
    public struct Script: Serializable, Deserializable {
        public let bytecode: [UInt8]
        public let typeArgs: [TypeTag]
        public let args: [ScriptFunctionArgument]

        public init(bytecode: [UInt8], typeArgs: [TypeTag], args: [ScriptFunctionArgument]) {
            self.bytecode = bytecode
            self.typeArgs = typeArgs
            self.args = args
        }

        public func serialize(serializer: Serializer) throws {
            try serializer.serializeBytes(value: bytecode)
            try serializer.serializeVector(values: typeArgs)
            try serializer.serializeVariantIndex(value: UInt32(args.count))
            for arg in args {
                try arg.serializeForScriptFunction(serializer: serializer)
            }
        }

        public static func deserialize(deserializer: Deserializer) throws -> Script {
            let bytecode = try deserializer.deserializeBytes()
            let typeArgs = try deserializer.deserializeVector(TypeTag.self)
            let length = try deserializer.deserializeVariantIndex()
            var args = [ScriptFunctionArgument]()
            for _ in 0..<length {
                args.append(try deserializeFromScriptArgument(deserializer: deserializer))
            }
            return .init(bytecode: bytecode, typeArgs: typeArgs, args: args)
        }
    }
}

extension TransactionPayload {
  public struct MultiSig: Serializable, Deserializable {
    public let multisigAddress: AccountAddress
    public let transactionPayload: Payload?

    public init(multisigAddress: AccountAddress, transactionPayload: Payload?) {
      self.multisigAddress = multisigAddress
      self.transactionPayload = transactionPayload
    }

    public func serialize(serializer: Serializer) throws {
      try multisigAddress.serialize(serializer: serializer)
      if let transactionPayload = transactionPayload {
        try serializer.serializeBool(value: true)
        try transactionPayload.serialize(serializer: serializer)
      } else {
        try serializer.serializeBool(value: false)
      }
    }

    public static func deserialize(deserializer: Deserializer) throws -> MultiSig {
      let multisigAddress = try AccountAddress.deserialize(deserializer: deserializer)
      let payloadPresent = try deserializer.deserializeBool()
      var transactionPayload: Payload?
      if payloadPresent {
        transactionPayload = try Payload.deserialize(deserializer: deserializer)
      }
      return .init(multisigAddress: multisigAddress, transactionPayload: transactionPayload)
    }
  }
}

extension TransactionPayload.MultiSig {
  public struct Payload: Serializable, Deserializable {
    public let transactionPayload: TransactionPayload.EntryFunction

    public init(transactionPayload: TransactionPayload.EntryFunction) {
      self.transactionPayload = transactionPayload
    }

    public func serialize(serializer: Serializer) throws {
      try serializer.serializeVariantIndex(value: 0)
      try transactionPayload.serialize(serializer: serializer)
    }

    public static func deserialize(deserializer: Deserializer) throws -> Payload {
      _ = try deserializer.deserializeVariantIndex()
      return .init(transactionPayload: try TransactionPayload.EntryFunction.deserialize(deserializer: deserializer))
    }
  }
}


private func deserializeFromScriptArgument(deserializer: Deserializer) throws -> TransactionArgument {
    let index = try deserializer.deserializeVariantIndex()
    switch index {
        case ScriptTransactionArgumentVariants.U8.rawValue:
            return try U8.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U64.rawValue:
            return try U64.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U128.rawValue:
            return try U128.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.Address.rawValue:
            return try AccountAddress.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U8Vector.rawValue:
            return try MoveVector<U8>.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.Bool.rawValue:
            return try Boolean.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U16.rawValue:
            return try U16.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U32.rawValue:
            return try U32.deserialize(deserializer: deserializer)
        case ScriptTransactionArgumentVariants.U256.rawValue:
            return try U256.deserialize(deserializer: deserializer)
        default:
            throw TransactionPayloadError.invalidVariantIndex
    }
}