import Foundation

public struct Boolean: Serializable, Deserializable {
  public let value: Bool

  public init(value: Bool) {
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeBool(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> Boolean {
      return try Boolean(value: deserializer.deserializeBool())
  }
 
}

public struct U8: Serializable, Deserializable {
  public let value: UInt8

  public init(value: UInt8) {
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU8(value: value)
  }


  public static func deserialize(deserializer: Deserializer) throws -> U8 {
      return try U8(value: deserializer.deserializeU8())
  }
}

public struct U16: Serializable, Deserializable {
  public let value: UInt16

  public init(value: UInt16) {
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU16(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> U16 {
      return try U16(value: deserializer.deserializeU16())
  }
}

public struct U32: Serializable, Deserializable {
  public let value: UInt32

  public init(value: UInt32) {
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU32(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> U32 {
      return try U32(value: deserializer.deserializeU32())
  }
}

public struct U64: Serializable, Deserializable {
  public let value: UInt64

  public init(value: UInt64) {
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU64(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> U64 {
      return try U64(value: deserializer.deserializeU64())
  }
}

public struct U128: Serializable, Deserializable {
  public let value: UInt128

  public init(value: UInt128) throws {
      // check available u128 range
      // MAX_U128_BIG_INT
      guard value <= UInt128(MAX_U128_BIG_INT), value >= 0 else {
        throw SerializationError.invalidU128Value
      }
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU128(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> U128 {
      return try U128(value: deserializer.deserializeU128())
  }
}

public struct U256: Serializable, Deserializable {
  public let value: UInt256

  public init(value: UInt256) throws {
      // check available u256 range
      // MAX_U256_BIG_INT
      guard value <= UInt256(MAX_U256_BIG_INT), value >= 0 else {
        throw SerializationError.invalidU256Value
      }
      self.value = value
  }

  public func serialize(serializer: Serializer) throws {
    try serializer.serializeU256(value: value)
  }

  public static func deserialize(deserializer: Deserializer) throws -> U256 {
      return try U256(value: deserializer.deserializeU256())
  }
}