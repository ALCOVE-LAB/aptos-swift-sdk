import Foundation

public class BinaryDeserializer: Deserializer {
    let input: [UInt8]
    private var location: Int
    private var containerDepthBudget: Int

    init(input: [UInt8], maxContainerDepth: Int) {
        self.input = input
        location = 0
        containerDepthBudget = maxContainerDepth
    }

    private func readBytes(count: Int) throws -> [UInt8] {
        let newLocation = location + count
        if newLocation > input.count {
            throw DeserializationError.invalidInput(issue: "Input is too small")
        }
        let bytes = input[location ..< newLocation]
        location = newLocation
        return Array(bytes)
    }

    public func deserializeLen() throws -> Int {
        assertionFailure("Not implemented")
        return 0
    }

    public func deserializeVariantIndex() throws -> UInt32 {
        assertionFailure("Not implemented")
        return 0
    }

    public func deserializeChar() throws -> Character {
        throw DeserializationError.invalidInput(issue: "Not implemented: char deserialization")
    }

    public func deserializeF32() throws -> Float {
        throw DeserializationError.invalidInput(issue: "Not implemented: f32 deserialization")
    }

    public func deserializeF64() throws -> Double {
        throw DeserializationError.invalidInput(issue: "Not implemented: f64 deserialization")
    }

    public func increaseContainerDepth() throws {
        if containerDepthBudget == 0 {
            throw DeserializationError.invalidInput(issue: "Exceeded maximum container depth")
        }
        containerDepthBudget -= 1
    }

    public func decreaseContainerDepth() {
        containerDepthBudget += 1
    }

    public func deserializeStr() throws -> String {
        let bytes = try deserializeBytes()
        guard let value = String(bytes: bytes, encoding: .utf8) else {
            throw DeserializationError.invalidInput(issue: "Incorrect UTF8 string")
        }
        return value
    }

    public func deserializeBytes() throws -> [UInt8] {
        let len = try deserializeLen()
        let content = try readBytes(count: len)
        return content
    }

    public func deserializeFixedBytes(_ len: Int) throws -> [UInt8] {
        return try readBytes(count: len)
    }

    public func deserializeBool() throws -> Bool {
        let value = try deserializeU8()
        switch value {
        case 0: return false
        case 1: return true
        default: throw DeserializationError.invalidInput(issue: "Incorrect value for boolean: \(value)")
        }
    }

    public func deserializeU8() throws -> UInt8 {
        let bytes = try readBytes(count: 1)
        return bytes[0]
    }

    public func deserializeU16() throws -> UInt16 {
        let bytes = try readBytes(count: 2)
        var x = UInt16(bytes[0])
        x += UInt16(bytes[1]) << 8
        return x
    }

    public func deserializeU32() throws -> UInt32 {
        let bytes = try readBytes(count: 4)
        var x = UInt32(bytes[0])
        x += UInt32(bytes[1]) << 8
        x += UInt32(bytes[2]) << 16
        x += UInt32(bytes[3]) << 24
        return x
    }

    

    public func deserializeU64() throws -> UInt64 {
        let bytes = try readBytes(count: 8)
        var x = UInt64(bytes[0])
        x += UInt64(bytes[1]) << 8
        x += UInt64(bytes[2]) << 16
        x += UInt64(bytes[3]) << 24
        x += UInt64(bytes[4]) << 32
        x += UInt64(bytes[5]) << 40
        x += UInt64(bytes[6]) << 48
        x += UInt64(bytes[7]) << 56
        return x
    }
    
    public func deserializeU128() throws -> UInt128 {
        let low = try deserializeU64()
        let high = try deserializeU64()
        return UInt128((UInt128(high) << UInt128(64)) | UInt128(low));
    }

    public func deserializeU256() throws -> UInt256 {
        let low = try deserializeU128()
        let high = try deserializeU128()
        return UInt256((high) << (128) | UInt128(low));
    }

    public func deserializeI8() throws -> Int8 {
        return Int8(bitPattern: try deserializeU8())
    }

    public func deserializeI16() throws -> Int16 {
        return Int16(bitPattern: try deserializeU16())
    }

    public func deserializeI32() throws -> Int32 {
        return Int32(bitPattern: try deserializeU32())
    }

    public func deserializeI64() throws -> Int64 {
        return Int64(bitPattern: try deserializeU64())
    }

    public func deserializeI128() throws -> Int128 {
        let low = try deserializeU64()
        let high = try deserializeI64()
        return Int256((UInt64(high) << 64) | low)
    }

    public func deserializeI256() throws -> Int256 {
        let low = try deserializeI128()
        let high = try deserializeI128()
        return Int256((high << 128) | low)
    }

    public func deserializeOptionTag() throws -> Bool {
        let value = try deserializeU8()
        switch value {
            case 0: return false
            case 1: return true
            default: throw DeserializationError.invalidInput(issue: "Incorrect value for option tag: \(value)")
        }
    }

    public func getBufferOffset() -> Int {
        return location
    }

    public func checkThatKeySlicesAreIncreasing(key1 _: Slice, key2 _: Slice) throws {
        assertionFailure("Not implemented")
    }
}
