import Foundation

public class BinarySerializer: Serializer {
    var output: [UInt8]
    private var containerDepthBudget: Int

    public init(maxContainerDepth: Int) {
        output = []
        output.reserveCapacity(64)
        containerDepthBudget = maxContainerDepth
    }

    public func increaseContainerDepth() throws {
        if containerDepthBudget == 0 {
            throw SerializationError.invalidValue(issue: "Exceeded maximum container depth")
        }
        containerDepthBudget -= 1
    }

    public func decreaseContainerDepth() {
        containerDepthBudget += 1
    }

    public func serializeChar(value _: Character) throws {
        throw SerializationError.invalidValue(issue: "Not implemented: char serialization")
    }

    public func serializeF32(value: Float) throws {
        throw SerializationError.invalidValue(issue: "Not implemented: f32 serialization")
    }

    public func serializeF64(value: Double) throws {
        throw SerializationError.invalidValue(issue: "Not implemented: f64 serialization")
    }

    public func getBytes() -> [UInt8] {
        return output
    }

    public func serializeStr(value: String) throws {
        try serializeBytes(value: Array(value.utf8))
    }

    public func serializeBytes(value: [UInt8]) throws {
        try serializeLen(value: value.count)
        output.append(contentsOf: value)
    }

    public func serializeFixedBytes(value: [UInt8]) throws {
        output.append(contentsOf: value)
    }

    public func serializeBool(value: Bool) throws {
        writeByte(value ? 1 : 0)
    }

    func writeByte(_ value: UInt8) {
        output.append(value)
    }

    public func serializeU8(value: UInt8) throws {
        writeByte(value)
    }

    public func serializeU16(value: UInt16) throws {
        writeByte(UInt8(truncatingIfNeeded: value))
        writeByte(UInt8(truncatingIfNeeded: value >> 8))
    }

    public func serializeU32(value: UInt32) throws {
        writeByte(UInt8(truncatingIfNeeded: value))
        writeByte(UInt8(truncatingIfNeeded: value >> 8))
        writeByte(UInt8(truncatingIfNeeded: value >> 16))
        writeByte(UInt8(truncatingIfNeeded: value >> 24))
    }

    public func serializeU64(value: UInt64) throws {
        writeByte(UInt8(truncatingIfNeeded: value))
        writeByte(UInt8(truncatingIfNeeded: value >> 8))
        writeByte(UInt8(truncatingIfNeeded: value >> 16))
        writeByte(UInt8(truncatingIfNeeded: value >> 24))
        writeByte(UInt8(truncatingIfNeeded: value >> 32))
        writeByte(UInt8(truncatingIfNeeded: value >> 40))
        writeByte(UInt8(truncatingIfNeeded: value >> 48))
        writeByte(UInt8(truncatingIfNeeded: value >> 56))
    }

    public func serializeU128(value: UInt128) throws {
        if value < 0 || value > MAX_U128_BIG_INT {
            throw SerializationError.invalidValue(issue: "Invalid length value")
        }
        let low = UInt64(value & UInt128(UInt64.max))
        let high = UInt64(value >> 64)
        
        try serializeU64(value: low)
        try serializeU64(value: high)
    }
   
    public func serializeU256(value: UInt256) throws {
        if value < 0 || value > MAX_U256_BIG_INT {
            throw SerializationError.invalidValue(issue: "Invalid length value")
        }
        let low = value & MAX_U128_BIG_INT
        let high = value >> 128
        try serializeU128(value: low)
        try serializeU128(value: high)
    }

    public func serializeI8(value: Int8) throws {
        try serializeU8(value: UInt8(bitPattern: value))
    }

    public func serializeI16(value: Int16) throws {
        try serializeU16(value: UInt16(bitPattern: value))
    }

    public func serializeI32(value: Int32) throws {
        try serializeU32(value: UInt32(bitPattern: value))
    }

    public func serializeI64(value: Int64) throws {
        try serializeU64(value: UInt64(bitPattern: value))
    }

    public func serializeI128(value: Int128) throws {
        if value < 0 || value > MAX_I128_BIG_INT {
            throw SerializationError.invalidValue(issue: "Invalid length value")
        }
        let low = UInt64(value & Int128(UInt64.max))
        let high = Int64(value >> 64)
        try serializeU64(value: low)
        try serializeI64(value: high)
    }

    public func serializeI256(value: Int256) throws {
        if value < 0 || value > MAX_I256_BIG_INT {
            throw SerializationError.invalidValue(issue: "Invalid length value")
        }
        let low = value & MAX_I128_BIG_INT
        let high = value >> 128
        try serializeI128(value: low)
        try serializeI128(value: high)
    }


    public func serializeOptionTag(value: Bool) throws {
        writeByte(value ? 1 : 0)
    }

    public func getBufferOffset() -> Int {
        return output.count
    }

    public func serializeLen(value _: Int) throws {
        assertionFailure("Not implemented")
    }

    public func serializeVariantIndex(value _: UInt32) throws {
        assertionFailure("Not implemented")
    }

    public func sortMapEntries(offsets _: [Int]) {
        assertionFailure("Not implemented")
    }
}
