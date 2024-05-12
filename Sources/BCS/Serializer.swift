import Foundation

public enum SerializationError: Error {
    case invalidValue(issue: String)
}

public protocol Serializable {
  func serialize(serializer: Serializer) throws;
}

public protocol Serializer {
  func serializeStr(value: String) throws
  func serializeBytes(value: [UInt8]) throws
  func serializeFixedBytes(value: [UInt8]) throws
  func serializeBool(value: Bool) throws
  func serializeChar(value: Character) throws
  func serializeF32(value: Float) throws
  func serializeF64(value: Double) throws
  func serializeU8(value: UInt8) throws
  func serializeU16(value: UInt16) throws
  func serializeU32(value: UInt32) throws
  func serializeU64(value: UInt64) throws
  func serializeU128(value: UInt128) throws
  func serializeU256(value: UInt256) throws
  func serializeI8(value: Int8) throws
  func serializeI16(value: Int16) throws
  func serializeI32(value: Int32) throws
  func serializeI64(value: Int64) throws
  func serializeI128(value: Int128) throws
  func serializeI256(value: Int256) throws

  func serializeLen(value: Int) throws
  func serializeVariantIndex(value: UInt32) throws
  func serializeOptionTag(value: Bool) throws
  func increaseContainerDepth() throws
  func decreaseContainerDepth() throws
  func getBufferOffset() -> Int
  func sortMapEntries(offsets: [Int])
  func getBytes() -> [UInt8]
}


public extension Serializer {
  func serialize<T: Serializable>(value: T) throws {
        try value.serialize(serializer: self)
  }
  func serializeVector<T: Serializable>(values: Array<T>) throws {
        try serializeVariantIndex(value: UInt32(values.count))
        try values.forEach({ try $0.serialize(serializer: self)})
  }

  func toUInt8Array() -> [UInt8] {
    var result = self.getBytes()
    result = [UInt8](result[0..<self.getBufferOffset()])
    return result
  }
}
