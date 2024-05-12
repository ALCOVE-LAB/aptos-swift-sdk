import Foundation

public class BincodeDeserializer: BinaryDeserializer {
    public let MAX_LENGTH: Int = 1 << 31 - 1

    public init(input: [UInt8]) {
        super.init(input: input, maxContainerDepth: Int.max)
    }

    override public func deserializeLen() throws -> Int {
        let value = try deserializeI64()
        if value < 0 || value > MAX_LENGTH {
            throw DeserializationError.invalidInput(issue: "Incorrect length value")
        }
        return Int(value)
    }

    override public func deserializeF32() throws -> Float {
        let num = try deserializeU32()
        return Float(bitPattern: num)
    }

    override public func deserializeF64() throws -> Double {
        let num = try deserializeU64()
        return Double(bitPattern: num)
    }

    override public func deserializeVariantIndex() throws -> UInt32 {
        return try deserializeU32()
    }

    override public func checkThatKeySlicesAreIncreasing(key1 _: Slice, key2 _: Slice) throws {
        // Nothing to do
    }
}
