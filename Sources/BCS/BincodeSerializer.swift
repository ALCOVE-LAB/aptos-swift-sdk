import Foundation

public class BincodeSerializer: BinarySerializer {
    public let MAX_LENGTH: Int = 1 << 31 - 1

    public init() {
        super.init(maxContainerDepth: Int.max)
    }

    override public func serializeLen(value: Int) throws {
        if value < 0 || value > MAX_LENGTH {
            throw SerializationError.invalidValue(issue: "Invalid length value")
        }
        try serializeU64(value: UInt64(value))
    }

    override public func serializeF32(value: Float) throws {
        try serializeU32(value: value.bitPattern)
    }

    override public func serializeF64(value: Double) throws {
        try serializeU64(value: value.bitPattern)
    }

    override public func serializeVariantIndex(value: UInt32) throws {
        try serializeU32(value: value)
    }

    override public func sortMapEntries(offsets _: [Int]) {
        // Not required by the format.
    }
}
