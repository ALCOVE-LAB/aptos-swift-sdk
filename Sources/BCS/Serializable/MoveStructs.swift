import Foundation

public struct MoveVector<T>: Serializable {
	public let value: [T]
	public init(value: [T]) {
		self.value = value
	}

	public func serialize(serializer: Serializer) throws {
		if let value = value as? [Serializable] {
			try serializer.serializeVector(values: value)
		}
	}
}

extension MoveVector: Deserializable where T: Deserializable {
	public static func deserialize(deserializer: Deserializer) throws -> MoveVector<T> {
		let values: [T] = try deserializer.deserializeVector(T.self)
		return .init(value: values)
	}
}

public extension MoveVector {

	static func U8(_ values: [UInt8]) -> MoveVector<U8> {
		return .init(value: values.map { BCS.U8(value: $0) })
	}

	static func U16(_ values: [UInt16]) -> MoveVector<U16> {
		return .init(value: values.map { BCS.U16(value: $0) })
	}

	static func U32(_ values: [UInt32]) -> MoveVector<U32> {
		return .init(value: values.map { BCS.U32(value: $0) })
	}

	static func U64(_ values: [UInt64]) -> MoveVector<U64> {
		return .init(value: values.map { BCS.U64(value: $0) })
	}

	static func U128(_ values: [UInt128]) throws -> MoveVector<U128> {
		return try .init(value: values.map { try BCS.U128(value: $0) })
	}

	static func U256(_ values: [UInt256]) throws -> MoveVector<U256> {
		return try .init(value: values.map { try BCS.U256(value: $0) })
	}
	
	static func Boolean(_ values: [Bool]) -> MoveVector<Boolean> {
		return .init(value: values.map { BCS.Boolean(value: $0) })
	}

	static func String(_ values: [String]) -> MoveVector<MoveString> {
		return .init(value: values.map { BCS.MoveString(value: $0) })
	}
}

public struct MoveString: Serializable, Deserializable {

	public let value: String
	public init(value: String) {
		self.value = value
	}
	public func serialize(serializer: Serializer) throws {
		try serializer.serializeStr(value: value)
	}

	public static func deserialize(deserializer: Deserializer) throws -> MoveString {
		return .init(value: try deserializer.deserializeStr())
	}

}
public struct MoveOption<T>: Serializable {
	public let vec: MoveVector<T>
	public let value: T?
	public init(value: T?) {
		self.value = value
		switch value {
			case .none:
				self.vec = MoveVector(value: [])
			case .some(let value):
				self.vec = MoveVector(value: [value])	
		}
	}

	public func serialize(serializer: Serializer) throws {
		try vec.serialize(serializer: serializer)
	}
}
extension MoveOption: Deserializable where T: Deserializable {
	public static func deserialize(deserializer: Deserializer) throws -> MoveOption<T> {
		let vector = try MoveVector<T>.deserialize(deserializer: deserializer)
		return .init(value: vector.value.first)
	}
}

public extension MoveOption {
	var unwrap: T {
		switch value {
			case .none:
				fatalError("Called unwrap on a MoveOption with no value")
			case .some(let value):
				return value
		}
	}

	var isSome: Bool {
		return value != nil
	}
	
	static func U8(_ value: UInt8?) -> MoveOption<U8> {
		return .init(value: value.map { BCS.U8(value: $0) })
	}

	static func U16(_ value: UInt16?) -> MoveOption<U16> {
		return .init(value: value.map { BCS.U16(value: $0) })
	}

	static func U32(_ value: UInt32?) -> MoveOption<U32> {
		return .init(value: value.map { BCS.U32(value: $0) })
	}

	static func U64(_ value: UInt64?) -> MoveOption<U64> {
		return .init(value: value.map { BCS.U64(value: $0) })
	}

	static func U128(_ value: UInt128?) throws -> MoveOption<U128> {
		return .init(value: try value.map { try BCS.U128(value: $0) })
	}

	static func U256(_ value: UInt256?) throws -> MoveOption<U256> {
		return .init(value: try value.map { try BCS.U256(value: $0) })
	}

	static func Boolean(_ value: Bool?) -> MoveOption<Boolean> {
		return .init(value: value.map { BCS.Boolean(value: $0) })
	}

	static func String(_ value: String?) -> MoveOption<MoveString> {
		return .init(value: value.map { BCS.MoveString(value: $0) })
	}
}
