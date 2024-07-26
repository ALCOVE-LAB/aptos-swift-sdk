import XCTest
import Transactions
import BCS

class TypeTagTest: XCTestCase {
    struct ExpectedTypeTag {
        let string: String
        let address: String
        let moduleName: String
        let name: String
    }
    let expectedTypeTag = ExpectedTypeTag(
        string: "0x1::some_module::SomeResource",
        address: "0x1",
        moduleName: "some_module",
        name: "SomeResource"
    )

    func testDeserializeTypeTags() throws {
        try [
            TypeTag.Bool,
            TypeTag.U8,
            TypeTag.U16, 
            TypeTag.U32, 
            TypeTag.U64, 
            TypeTag.U128, 
            TypeTag.U256, 
            TypeTag.Address, 
            TypeTag.Signer,
            TypeTag.Vector(TypeTag.U32),
            TypeTag.Reference(TypeTag.U32),
            TypeTag.Generic(UInt32.max)
        ].forEach { tag in
            let serializer = BcsSerializer()
            try tag.serialize(serializer: serializer)
            let deserialized = try TypeTag.deserialize(deserializer: BcsDeserializer(input: serializer.toUInt8Array()))
            
            XCTAssert(deserialized == tag)
        }

        try test("deserializes a TypeTagStruct correctly", {
            let serializer = BcsSerializer()
            let tag = try TypeTag.parseTypeTag(expectedTypeTag.string)
            try tag.serialize(serializer: serializer)
            let deserialized = try TypeTag.deserialize(deserializer: BcsDeserializer(input: serializer.toUInt8Array()))

            if case let .Struct(value) = deserialized {
                XCTAssert(value.address.toString() == expectedTypeTag.address)
                XCTAssert(value.moduleName.identifier == expectedTypeTag.moduleName)
                XCTAssert(value.name.identifier == expectedTypeTag.name)
                XCTAssert(value.typeArgs.isEmpty)
            } else {
                XCTFail("Expected deserialized value to be a TypeTagStruct")
            }
        })
    }
}
