import Foundation
import BCS 
import Types

public protocol TransactionArgument: EntryFunctionArgument, ScriptFunctionArgument {}

public protocol EntryFunctionArgument: Serializable {
    func serialize(serializer: Serializer) throws
    func serializeForEntryFunction(serializer: Serializer) throws
    func bcsToBytes() throws -> [UInt8] 
}

public protocol ScriptFunctionArgument: Serializable {
    func serialize(serializer: Serializer) throws
    func serializeForScriptFunction(serializer: Serializer) throws
    func bcsToBytes() throws -> [UInt8] 
}

extension EntryFunctionArgument {
    public func serializeForEntryFunction(serializer: Serializer) throws {
        let bcsBytes = try bcsToBytes()
        try serializer.serializeBytes(value: bcsBytes);
    }
}

extension Boolean: TransactionArgument {
  public func serializeForScriptFunction(serializer: Serializer) throws {
    try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.Bool.rawValue)
    try serializer.serialize(value: self)
  }
}
extension U8: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U8.rawValue)
        try serializer.serialize(value: self)
    }
}
extension U16: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U16.rawValue)
        try serializer.serialize(value: self)
    }
}
extension U32: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U32.rawValue)
        try serializer.serialize(value: self)
    }
}
extension U64: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U64.rawValue)
        try serializer.serialize(value: self)
    }
}
extension U128: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U128.rawValue)
        try serializer.serialize(value: self)
    }
}
extension U256: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U256.rawValue)
        try serializer.serialize(value: self)
    }
}

extension FixedBytes: TransactionArgument {

    public func serializeForEntryFunction(serializer: Serializer) throws {
        try serializer.serialize(value: self)
    }
    
    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serialize(value: self)
    }
}

extension EntryFunctionBytes: EntryFunctionArgument {
    public func serializeForEntryFunction(serializer: Serializer) throws {
      try serializer.serializeVariantIndex(value: UInt32(value.value.count))
      try serializer.serialize(value: self)
    }
}

extension MoveString: TransactionArgument {
	public func serializeForScriptFunction(serializer: Serializer) throws {
		let fixedStringBytes = try bcsToBytes().dropFirst()
		let vectorU8 = MoveVector<U8>.U8(Array(fixedStringBytes))
		try vectorU8.serializeForScriptFunction(serializer: serializer)
	}
}

extension MoveVector: TransactionArgument {

	public func serializeForScriptFunction(serializer: Serializer) throws {
		guard let first = value.first, first is U8 else {
			// only accept u8 vectors
			throw SerializationError.invalidU8Vector
		}
		try serializer.serializeVariantIndex(value: ScriptTransactionArgumentVariants.U8Vector.rawValue)
		try serializer.serialize(value: self)
	}
	
}
extension MoveOption: TransactionArgument {
    public func serializeForScriptFunction(serializer: Serializer) throws {
		try vec.serializeForScriptFunction(serializer: serializer)
	}
}

extension AccountAddress: TransactionArgument {
    
    public func serializeForEntryFunction(serializer: Serializer) throws {
        let bcsBytes = try self.bcsToBytes()
        try serializer.serializeBytes(value: bcsBytes)
    }

    public func serializeForScriptFunction(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: UInt32(ScriptTransactionArgumentVariants.Address.rawValue))
        try serializer.serialize(value: self)
    }

}