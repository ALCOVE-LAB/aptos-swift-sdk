import Foundation

public class BcsDeserializer: BinaryDeserializer {
    public let MAX_LENGTH: Int = 1 << 31 - 1
    public let MAX_CONTAINER_DEPTH: Int = 500

    public init(input: [UInt8]) {
        super.init(input: input, maxContainerDepth: MAX_CONTAINER_DEPTH)
    }
    
    private func deserializeUleb128AsU32() throws -> UInt32 {
        var value: UInt64 = 0
        for shift in stride(from: 0, to: 32, by: 7) {
            let x = try deserializeU8()
            let digit = x & 0x7F
            value |= UInt64(digit) << shift
            if value > UInt32.max {
                throw DeserializationError.invalidInput(issue: "Overflow while parsing uleb128-encoded uint32 value")
            }
            if digit == x {
                if shift > 0, digit == 0 {
                    throw DeserializationError.invalidInput(issue: "Invalid uleb128 number (unexpected zero digit)")
                }
                return UInt32(value)
            }
        }
        throw DeserializationError.invalidInput(issue: "Overflow while parsing uleb128-encoded uint32 value")
    }


    override public func deserializeLen() throws -> Int {
        let value = try deserializeUleb128AsU32()
        if value > MAX_LENGTH {
            throw DeserializationError.invalidInput(issue: "Overflow while parsing length value")
        }
        return Int(value)
    }

    override public func deserializeVariantIndex() throws -> UInt32 {
        return try deserializeUleb128AsU32()
    }

    override public func checkThatKeySlicesAreIncreasing(key1: Slice, key2: Slice) throws {
        guard input[key1.start ..< key1.end].lexicographicallyPrecedes(input[key2.start ..< key2.end]) else {
            throw DeserializationError.invalidInput(issue: "Invalid ordering of keys")
        }
    }
}
