import Foundation

public enum DeserializationError: Error {
  case invalidInput(issue: String)
}
public protocol Deserializable {
  static func deserialize(deserializer: Deserializer) throws -> Self
}

public protocol Deserializer {
  func deserializeStr() throws -> String
  func deserializeBytes() throws -> [UInt8]
  func deserializeFixedBytes(_ len: Int) throws -> [UInt8]
  func deserializeBool() throws -> Bool
  func deserializeChar() throws -> Character
  func deserializeF32() throws -> Float
  func deserializeF64() throws -> Double
  func deserializeU8() throws -> UInt8
  func deserializeU16() throws -> UInt16
  func deserializeU32() throws -> UInt32
  func deserializeU64() throws -> UInt64
  func deserializeU128() throws -> UInt128
  func deserializeU256() throws -> UInt256
  func deserializeI8() throws -> Int8
  func deserializeI16() throws -> Int16
  func deserializeI32() throws -> Int32
  func deserializeI64() throws -> Int64
  func deserializeI128() throws -> Int128
  func deserializeI256() throws -> Int256

  func deserializeLen() throws -> Int
  func deserializeVariantIndex() throws -> UInt32
  func deserializeOptionTag() throws -> Bool
  func getBufferOffset() -> Int
  func checkThatKeySlicesAreIncreasing(key1: Slice, key2: Slice) throws
  func increaseContainerDepth() throws
  func decreaseContainerDepth() throws

}

public extension Deserializer {
  func deserialize<T>(_ value: T.Type) throws -> T where T: Deserializable {
      return try value.deserialize(deserializer: self)
  }

  func deserializeVector<T>(_ value:  T.Type) throws -> Array<T> where T: Deserializable {
      let length = try deserializeVariantIndex()
      var vector = Array<T>()
      for _ in 0 ..< length {
          vector.append(try deserialize(value))
      }
      return vector
  }
}