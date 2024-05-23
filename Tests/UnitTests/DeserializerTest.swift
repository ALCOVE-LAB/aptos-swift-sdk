import BCS
import XCTest
import Foundation
import Types

class DeserializerTest: XCTestCase {

    func testDeserializesAnEmptyString() throws {
        let deserializer = BcsDeserializer(input: [0])
        let result = try deserializer.deserializeStr()
        XCTAssertEqual(result, "", "should match")
    }

    func testDeserializeStr() throws {
        let d = BcsDeserializer(input: [
            24, 0xc3, 0xa7, 0xc3, 0xa5, 0xe2, 0x88, 0x9e, 0xe2, 0x89, 0xa0, 0xc2, 0xa2, 0xc3, 0xb5, 0xc3, 0x9f, 0xe2, 0x88,
            0x82, 0xc6, 0x92, 0xe2, 0x88, 0xab
        ])
        let result = try d.deserializeStr()
        XCTAssertEqual(result, "çå∞≠¢õß∂ƒ∫", "should match")
    }

    func testDeserializesDynamicLengthBytes() throws {
        let deserializer = BcsDeserializer(input: [5, 0x41, 0x70, 0x74, 0x6f, 0x73])
        let result = try deserializer.deserializeBytes()
        XCTAssertEqual(result, [0x41, 0x70, 0x74, 0x6f, 0x73], "should match")
    }

    func testDeserializesDynamicLengthBytesWithZeroElements() throws {
        let deserializer = BcsDeserializer(input: [0])
        let result = try deserializer.deserializeBytes()
        XCTAssertEqual(result, [], "should match")
    }

    func testDeserializesFixedLengthBytes() throws {
        let deserializer = BcsDeserializer(input: [0x41, 0x70, 0x74, 0x6f, 0x73])
        let result = try deserializer.deserializeFixedBytes(5)
        XCTAssertEqual(result, [0x41, 0x70, 0x74, 0x6f, 0x73], "should match")
    }

    func testDeserializesFixedLengthBytesWithZeroElement() throws {
        let deserializer = BcsDeserializer(input: [])
        let result = try deserializer.deserializeFixedBytes(0)
        XCTAssertEqual(result, [], "should match")
    }

    func testDeserializesABooleanValue() throws {
        var deserializer = BcsDeserializer(input: [0x01])
        var result = try deserializer.deserializeBool()
        XCTAssertEqual(result, true, "should match")
        deserializer = BcsDeserializer(input: [0x00])
        result = try deserializer.deserializeBool()
        XCTAssertEqual(result, false, "should match")
    }
        
    func testThrowsWhenDeserializingABooleanWithDisallowedValues() {
        let deserializer = BcsDeserializer(input: [0x12])
        XCTAssertThrowsError(try deserializer.deserializeBool())
        // 'Invalid boolean value'
    }

    func testDeserializesAUInt8() throws {
        let deserializer = BcsDeserializer(input: [0xff])
        let result = try deserializer.deserializeU8()
        XCTAssertEqual(result, 255, "should match")
    }

    func testDeserializesAUInt16() throws {
        var deserializer = BcsDeserializer(input: [0xff, 0xff])
        var result = try deserializer.deserializeU16()
        XCTAssertEqual(result, 65535, "should match")
        deserializer = BcsDeserializer(input: [0x34, 0x12])
        result = try deserializer.deserializeU16()
        XCTAssertEqual(result, 4660, "should match")
    }

    func testDeserializesAUInt32() throws {
        var deserializer = BcsDeserializer(input: [0xff, 0xff, 0xff, 0xff])
        var result = try deserializer.deserializeU32()
        XCTAssertEqual(result, 4294967295, "should match")
        deserializer = BcsDeserializer(input: [0x78, 0x56, 0x34, 0x12])
        result = try deserializer.deserializeU32()
        XCTAssertEqual(result, 305419896, "should match")
    }

    func testDeserializesAUInt64() throws {
        var deserializer = BcsDeserializer(input: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        var result = try deserializer.deserializeU64()
        XCTAssertEqual(result, 18446744073709551615, "should match")
        deserializer = BcsDeserializer(input: [0x00, 0xef, 0xcd, 0xab, 0x78, 0x56, 0x34, 0x12])
        result = try deserializer.deserializeU64()
        XCTAssertEqual(result, 1311768467750121216, "should match")
    }

    func testDeserializesAUInt128() throws {
        var deserializer = BcsDeserializer(input: [0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        var result = try deserializer.deserializeU128()
        XCTAssertEqual(result, UInt128("340282366920938463463374607431768211455"), "should match")
        deserializer = BcsDeserializer(input: [0x00, 0xef, 0xcd, 0xab, 0x78, 0x56, 0x34, 0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        result = try deserializer.deserializeU128()
        XCTAssertEqual(result, 1311768467750121216, "should match")
    }
    
    func testDeserializesAUInt256() throws {
        let deserializer = BcsDeserializer(input: [
            0x31, 0x30, 0x29, 0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21, 0x20, 0x19, 0x18, 0x17, 0x16, 0x15, 0x14,
            0x13, 0x12, 0x11, 0x10, 0x09, 0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00
        ])
        XCTAssertEqual(try deserializer.deserializeU256(), UInt256.init("0001020304050607080910111213141516171819202122232425262728293031", radix: 16), "should match")
    }

    func testDeserializesAULeb128() throws {
        var deserializer = BcsDeserializer(input: [0xcd, 0xea, 0xec, 0x31])
        var result = try deserializer.deserializeVariantIndex()
        XCTAssertEqual(result, 104543565, "should match")
        deserializer = BcsDeserializer(input: [0xff, 0xff, 0xff, 0xff, 0x0f])
        result = try deserializer.deserializeVariantIndex()
        XCTAssertEqual(result, 4294967295, "should match")
    }

    func testThrowsWhenDeserializingAULeb128WithOutOfRangeValue() {
        let deserializer = BcsDeserializer(input: [0x80, 0x80, 0x80, 0x80, 0x10])
        XCTAssertThrowsError(try deserializer.deserializeVariantIndex())
        // 'Overflow while parsing uleb128-encoded uint32 value'
    }

    func testThrowsWhenDeserializingAgainstBufferThatHasBeenDrained() throws {
        let deserializer = BcsDeserializer(input: [
            24, 0xc3, 0xa7, 0xc3, 0xa5, 0xe2, 0x88, 0x9e, 0xe2, 0x89, 0xa0, 0xc2, 0xa2, 0xc3, 0xb5, 0xc3, 0x9f, 0xe2,
            0x88, 0x82, 0xc6, 0x92, 0xe2, 0x88, 0xab
        ])
        let _ = try deserializer.deserializeStr()
        XCTAssertThrowsError(try deserializer.deserializeStr())
        // 'Reached to the end of buffer'
    }

    func testDeserializesAVectorOfDeserializableTypesCorrectly() throws {
        let addresses = [
            try AccountAddress.from("0x1"),
            try AccountAddress.from("0xa"),
            try AccountAddress.from("0x0123456789abcdef")
        ]
        let serializer = BcsSerializer()
        try serializer.serializeVector(values: (addresses))
        let serializedBytes = serializer.toUInt8Array()
        let deserializer = BcsDeserializer(input: serializedBytes)

        let deserializerAddresses = try deserializer.deserializeVector(AccountAddress.self)
        for (i, address) in addresses.enumerated() {
            XCTAssertEqual(address, deserializerAddresses[i], "should match")
        }
    }

    func testDeserializesASingleDeserializableClass() throws {
        struct MoveStruct: Serializable, Deserializable {
            static func deserialize(deserializer: BCS.Deserializer) throws -> MoveStruct {
                let name = try deserializer.deserializeStr()
                let description = try deserializer.deserializeStr()
                let enabled = try deserializer.deserializeBool()
                let length = try deserializer.deserializeVariantIndex()
                var vectorU8 = [UInt8]()
                for _ in 0..<length {
                    vectorU8.append(try deserializer.deserializeU8())
                }
                return MoveStruct(name: name, description: description, enabled: enabled, vectorU8: vectorU8)
            }

            func serialize(serializer: BCS.Serializer) throws {
                try serializer.serializeStr(value: name)
                try serializer.serializeStr(value: description)
                try serializer.serializeBool(value: enabled)
                try serializer.serializeVariantIndex(value: UInt32(vectorU8.count))
                try vectorU8.forEach { item in
                    try serializer.serializeU8(value: item)
                }
            }
            let name: String
            let description: String
            let enabled: Bool
            let vectorU8: [UInt8]
        }

        let moveStruct = MoveStruct(name: "abc", description: "123", enabled: false, vectorU8: [1, 2, 3, 4])
        let serializer = BcsSerializer()
        try serializer.serialize(value: moveStruct)
        let moveStructBcsBytes = serializer.toUInt8Array()
        let deserializer = BcsDeserializer(input: moveStructBcsBytes)
        let deserializedMoveStruct = try MoveStruct.deserialize(deserializer: deserializer)
        XCTAssertEqual(deserializedMoveStruct.name, moveStruct.name, "should match")
        XCTAssertEqual(deserializedMoveStruct.description, moveStruct.description, "should match")
        XCTAssertEqual(deserializedMoveStruct.enabled, moveStruct.enabled, "should match")
        XCTAssertEqual(deserializedMoveStruct.vectorU8, moveStruct.vectorU8, "should match")
    }

    func testDeserializesAndComposesAnBbstractDeserializableClassInstanceFromComposedDeserializeCalls() throws {
        class MoveStruct: Serializable, Deserializable {
            static func deserialize(deserializer: BCS.Deserializer) throws -> MoveStruct {
                let index = try deserializer.deserializeVariantIndex()
                switch index {
                case 0:
                    return try MoveStructA.load(deserializer: deserializer)
                case 1:
                    return try MoveStructB.load(deserializer: deserializer)
                default:
                    throw DeserializationError.invalidInput(issue: "Invalid variant index")
                }
            }
            func serialize(serializer: Serializer) throws {
                fatalError("not implemented")
            }
        }

        class MoveStructA: MoveStruct {

            static func load(deserializer: Deserializer) throws -> MoveStructA {
                let name = try deserializer.deserializeStr()
                let description = try deserializer.deserializeStr()
                let enabled = try deserializer.deserializeBool()
                let length = try deserializer.deserializeVariantIndex()
                var vectorU8 = [UInt8]()
                for _ in 0..<length {
                    vectorU8.append(try deserializer.deserializeU8())
                }
                return MoveStructA(name: name, description: description, enabled: enabled, vectorU8: vectorU8)
            }
            
           override func serialize(serializer: BCS.Serializer) throws {
                try serializer.serializeVariantIndex(value: 0)
                try serializer.serializeStr(value: name)
                try serializer.serializeStr(value: description)
                try serializer.serializeBool(value: enabled)
                try serializer.serializeVariantIndex(value: UInt32(vectorU8.count))
                try vectorU8.forEach { item in
                    try serializer.serializeU8(value: item)
                }
            }
            let name: String
            let description: String
            let enabled: Bool
            let vectorU8: [UInt8]

            init(name: String, description: String, enabled: Bool, vectorU8: [UInt8]) {
                self.name = name
                self.description = description
                self.enabled = enabled
                self.vectorU8 = vectorU8
            }

        }

        class MoveStructB: MoveStruct {
            
            static func load(deserializer: Deserializer) throws -> MoveStructB {
                let moveStructA = try MoveStruct.deserialize(deserializer: deserializer) as! MoveStructA
                let name = try deserializer.deserializeStr()
                let description = try deserializer.deserializeStr()
                let length = try deserializer.deserializeVariantIndex()
                var vectorU8 = [UInt8]()
                for _ in 0..<length {
                    vectorU8.append(try deserializer.deserializeU8())
                }
                return MoveStructB(moveStructA: moveStructA, name: name, description: description, vectorU8: vectorU8)
            }

            override func serialize(serializer: BCS.Serializer) throws {
                try serializer.serializeVariantIndex(value: 1)
                try serializer.serialize(value: moveStructA)
                try serializer.serializeStr(value: name)
                try serializer.serializeStr(value: description)
                try serializer.serializeVariantIndex(value: UInt32(vectorU8.count))
                try vectorU8.forEach { item in
                    try serializer.serializeU8(value: item)
                }
            }

            let moveStructA: MoveStructA
            let name: String
            let description: String
            let vectorU8: [UInt8]

            init(moveStructA: MoveStructA, name: String, description: String, vectorU8: [UInt8]) {
                self.moveStructA = moveStructA
                self.name = name
                self.description = description
                self.vectorU8 = vectorU8
            }

        }

        let moveStructA = MoveStructA(name: "abc", description: "123", enabled: false, vectorU8: [1, 2, 3, 4])
        let moveStructAInsideB = MoveStructA(name: "def", description: "456", enabled: true, vectorU8: [5, 6, 7, 8])
        let moveStructB = MoveStructB(moveStructA: moveStructAInsideB, name: "ghi", description: "789", vectorU8: [9, 10, 11, 12])

        let serializer = BcsSerializer()
        try serializer.serialize(value: moveStructA)
        try serializer.serialize(value: moveStructB)
        let serializedBytes = serializer.toUInt8Array()

        let deserializer = BcsDeserializer(input: serializedBytes)
        let deserializedMoveStructA = try MoveStruct.deserialize(deserializer: deserializer) as! MoveStructA
        let deserializedMoveStructB = try MoveStruct.deserialize(deserializer: deserializer) as! MoveStructB

        XCTAssertEqual(deserializedMoveStructA.name, "abc", "should match")
        XCTAssertEqual(deserializedMoveStructA.description, "123", "should match")
        XCTAssertEqual(deserializedMoveStructA.enabled, false, "should match")
        XCTAssertEqual(deserializedMoveStructA.vectorU8, [1, 2, 3, 4], "should match")

        XCTAssertEqual(deserializedMoveStructB.moveStructA.name, "def", "should match")
        XCTAssertEqual(deserializedMoveStructB.moveStructA.description, "456", "should match")
        XCTAssertEqual(deserializedMoveStructB.moveStructA.enabled, true, "should match")
        XCTAssertEqual(deserializedMoveStructB.moveStructA.vectorU8, [5, 6, 7, 8], "should match")

        XCTAssertEqual(deserializedMoveStructB.name, "ghi", "should match")
        XCTAssertEqual(deserializedMoveStructB.description, "789", "should match")
        XCTAssertEqual(deserializedMoveStructB.vectorU8, [9, 10, 11, 12], "should match")
            
    }
    /*
    convert typescript into swift

  it("deserializes and composes an abstract Deserializable class instance from composed deserialize calls", () => {


    */



}