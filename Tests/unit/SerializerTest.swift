import BCS 
import XCTest
import Types

class SerializerTest: XCTestCase {

    func testSerializer() throws {
        var serializer = BcsSerializer()
        try serializer.serializeU8(value: 255)
        try serializer.serializeU32(value: 1)
        try serializer.serializeU32(value: 1)
        try serializer.serializeU32(value: 2)
        XCTAssertEqual(serializer.getBufferOffset(), 13, "the buffer size should be same")
        XCTAssertEqual(serializer.getBytes(), [255, 1, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0], "the array should be same")
        
        serializer = BcsSerializer()
        try serializer.serializeBytes(value: [0x41, 0x70, 0x74, 0x6f, 0x73])
        XCTAssertEqual(serializer.toUInt8Array(), [5, 0x41, 0x70, 0x74, 0x6f, 0x73], "the array should be same")

    }

    func testSerializeUInt8() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeU8(value: 255)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeU8()
        XCTAssertEqual(result, 255, "should be same")
    }

    func testSerializeUInt16() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeU16(value: 65535)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeU16()
        XCTAssertEqual(result, 65535, "should be same")
    }

    func testSerializeUInt32() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeU32(value: 4_294_967_295)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeU32()
        XCTAssertEqual(result, 4_294_967_295, "should be same")
    }

    func testSerializeInt8() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeU8(value: 127)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeU8()
        XCTAssertEqual(result, 127, "should be same")
    }

    func testSerializeInt16() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeI16(value: 32767)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeI16()
        XCTAssertEqual(result, 32767, "should be same")
    }

    func testSerializeInt32() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeI32(value: 2_147_483_647)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeI32()
        XCTAssertEqual(result, 2_147_483_647, "should be same")
    }

    func testSerializeInt64() throws {
        let serializer = BincodeSerializer()
        try serializer.serializeI64(value: 9_223_372_036_854_775_807)
        let deserializer = BincodeDeserializer(input: serializer.getBytes())
        let result = try deserializer.deserializeI64()
        XCTAssertEqual(result, 9_223_372_036_854_775_807, "should be same")
    }

    func testSerializeU128() throws {
        let serializer = BcsSerializer()
        XCTAssertNoThrow(try serializer.serializeU128(value: MAX_U128_BIG_INT))
        XCTAssertEqual(serializer.getBytes(), [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255], "the array should be same")

        let serializer2 = BcsSerializer()
        XCTAssertNoThrow(try serializer2.serializeU128(value: UInt128(1)))
        XCTAssertEqual(serializer2.getBytes(), [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")

        let serializer3 = BcsSerializer()
        XCTAssertNoThrow(try serializer3.serializeU128(value: UInt128(0)))
        XCTAssertEqual(serializer3.getBytes(), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")
    }

    func testSerializeI128() throws {
        let serializer = BcsSerializer()
        XCTAssertNoThrow(try serializer.serializeI128(value: MAX_I128_BIG_INT))
        XCTAssertEqual(serializer.getBytes(), [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 127], "the array should be same")

        let serializer2 = BcsSerializer()
        XCTAssertNoThrow(try serializer2.serializeI128(value: Int128(1)))
        XCTAssertEqual(serializer2.getBytes(), [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")

        let serializer3 = BcsSerializer()
        XCTAssertNoThrow(try serializer3.serializeI128(value: Int128(0)))
        XCTAssertEqual(serializer3.getBytes(), [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], "the array should be same")
    }

    func testBcsSerializeStr() throws {
        var s = BcsSerializer()
        try s.serializeStr(value: "çå∞≠¢õß∂ƒ∫");
        
        XCTAssertEqual(s.getBytes(), [
            24, 0xc3, 0xa7, 0xc3, 0xa5, 0xe2, 0x88, 0x9e, 0xe2, 0x89, 0xa0, 0xc2, 0xa2, 0xc3, 0xb5, 0xc3, 0x9f, 0xe2, 0x88,
            0x82, 0xc6, 0x92, 0xe2, 0x88, 0xab
        ], "the array should be same")

        s = BcsSerializer()
        try s.serializeStr(value: "abcd1234");
        XCTAssertEqual(s.getBytes(), [8, 0x61, 0x62, 0x63, 0x64, 0x31, 0x32, 0x33, 0x34], "the array should be same")

        s = BcsSerializer()    
        try s.serializeStr(value: "")
        XCTAssertEqual(s.getBytes(), [0], "the array should be same")
    }

    func testULEB128Encoding() throws {
        let serializer = BcsSerializer()
        try serializer.serializeLen(value: 0)
        try serializer.serializeLen(value: 1)
        try serializer.serializeLen(value: 127)
        try serializer.serializeLen(value: 128)
        try serializer.serializeLen(value: 3000)
        XCTAssertEqual(serializer.getBytes(), [0, 1, 127, 128, 1, 184, 23], "the array should be same")
    }

    func testSortMapEntries() throws {
        let s = BcsSerializer()
        try s.serializeU8(value: 255)
        try s.serializeU32(value: 1)
        try s.serializeU32(value: 1)
        try s.serializeU32(value: 2)
        XCTAssertEqual(s.getBytes(), [255 /**/, 1 /**/, 0, 0 /**/, 0, 1, 0 /**/, 0 /**/, 0 /**/, 2, 0, 0, 0])

        let offsets = [1, 2, 4, 7, 8, 9]
        s.sortMapEntries(offsets: offsets)
        XCTAssertEqual(s.getBytes(), [255 /**/, 0 /**/, 0 /**/, 0, 0 /**/, 0, 1, 0 /**/, 1 /**/, 2, 0, 0, 0])
    }

    func testSerializesMultipleTypesOfValues() throws {
        let serializer = BcsSerializer()
        try serializer.serializeBytes(value: [0x41, 0x70, 0x74, 0x6f, 0x73])
        try serializer.serializeBool(value: true)
        try serializer.serializeBool(value: false)
        try serializer.serializeU8(value: 254)
        try serializer.serializeU8(value: 255)
        try serializer.serializeU16(value: 65535)
        try serializer.serializeU16(value: 4660)
        try serializer.serializeU32(value: 4294967295)
        try serializer.serializeU32(value: 305419896)
        try serializer.serializeU64(value: 18446744073709551615)
        try serializer.serializeU64(value: 1311768467750121216)
        try serializer.serializeU128(value: UInt128("340282366920938463463374607431768211455"))
        try serializer.serializeU128(value: 1311768467750121216)
        let serializedBytes = serializer.getBytes()
        XCTAssertEqual(serializedBytes, [5, 0x41, 0x70, 0x74, 0x6f, 0x73, 0x01, 0x00, 0xfe, 0xff, 0xff, 0xff, 0x34, 0x12, 0xff, 0xff, 0xff, 0xff, 0x78,
        0x56, 0x34, 0x12, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xef, 0xcd, 0xab, 0x78, 0x56, 0x34,
        0x12, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00,
        0xef, 0xcd, 0xab, 0x78, 0x56, 0x34, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    }

    func testSerializesMultipleSerializableValues() throws {

        let moveStructA = MoveStructA(name: "abc", description: "123", enabled: false, vectorU8: [1, 2, 3, 4])
        let moveStructB = MoveStructB(moveStructA: moveStructA, name: "def", description: "456", vectorU8: [5, 6, 7, 8])

        let serializer = BcsSerializer()
        try serializer.serialize(value: moveStructB);
        let serializedBytes = serializer.getBytes();

        XCTAssertEqual(serializedBytes, [
            3, 0x61, 0x62, 0x63, 3, 0x31, 0x32, 0x33, 0x00, 4, 0x01, 0x02, 0x03, 0x04, 3, 0x64, 0x65, 0x66, 3, 0x34, 0x35,
            0x36, 4, 0x05, 0x06, 0x07, 0x08,
        ], "the array should be same")
    }

    struct MoveStructA: Serializable {
        let name: String
        let description: String
        let enabled: Bool
        let vectorU8: [UInt8]

        func serialize(serializer: Serializer) throws {
            try serializer.serializeStr(value: name)
            try serializer.serializeStr(value: description)
            try serializer.serializeBool(value: enabled)
            try serializer.serializeVariantIndex(value: UInt32(vectorU8.count))
            try vectorU8.forEach { item in
                try serializer.serializeU8(value: item)
            }
        }
    }

    struct MoveStructB: Serializable {
        let moveStructA: MoveStructA
        let name: String
        let description: String
        let vectorU8: [UInt8]
        
        func serialize(serializer: Serializer) throws {
            try serializer.serialize(value: moveStructA)
            try serializer.serializeStr(value: name)
            try serializer.serializeStr(value: description)
            try serializer.serializeVariantIndex(value: UInt32(vectorU8.count))
            try vectorU8.forEach { item in
                try serializer.serializeU8(value: item)
            }
        }
    }
}