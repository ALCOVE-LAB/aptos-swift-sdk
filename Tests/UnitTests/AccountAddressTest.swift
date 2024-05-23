import XCTest
import Types
import BCS

class AccountAddressTest: XCTestCase {

    struct Addresses {
        let shortWith0x: String
        let shortWithout0x: String
        let longWith0x: String
        let longWithout0x: String
        let bytes: [UInt8]
    }

    let ADDRESS_ZERO: Addresses = .init(
        shortWith0x: "0x0",
        shortWithout0x: "0",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000000",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000000",
        bytes: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ]
    )

    let ADDRESS_ONE: Addresses = .init(
        shortWith0x: "0x1",
        shortWithout0x: "1",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000001",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000001",
        bytes: [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
        ]
    )

    let ADDRESS_TWO: Addresses = .init(
        shortWith0x: "0x2",
        shortWithout0x: "2",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000002",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000002",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
        ]
    )

    let ADDRESS_THREE: Addresses = .init(
        shortWith0x: "0x3",
        shortWithout0x: "3",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000003",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000003",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3,
        ]
    )

    let ADDRESS_FOUR: Addresses = .init(
        shortWith0x: "0x4",
        shortWithout0x: "4",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000004",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000004",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4,
        ]
    )

    let ADDRESS_F: Addresses = .init(
        shortWith0x: "0xf",
        shortWithout0x: "f",
        longWith0x: "0x000000000000000000000000000000000000000000000000000000000000000f",
        longWithout0x: "000000000000000000000000000000000000000000000000000000000000000f",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15,
        ]
    )

    let ADDRESS_F_PADDED_SHORT_FORM: Addresses = .init(
        shortWith0x: "0x0f",
        shortWithout0x: "0f",
        longWith0x: "0x000000000000000000000000000000000000000000000000000000000000000f",
        longWithout0x: "000000000000000000000000000000000000000000000000000000000000000f",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15,
        ]
    )

    let ADDRESS_TEN: Addresses = .init(
        shortWith0x: "0x10",
        shortWithout0x: "10",
        longWith0x: "0x0000000000000000000000000000000000000000000000000000000000000010",
        longWithout0x: "0000000000000000000000000000000000000000000000000000000000000010",
        bytes: [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16,
        ]
    )

    let ADDRESS_OTHER: Addresses = .init(
        shortWith0x: "0xca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0",
        shortWithout0x: "ca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0",
        longWith0x: "0xca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0",
        longWithout0x: "ca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0",
        bytes: [
            202, 132, 50, 121, 227, 66, 113, 68, 206, 173, 94, 77, 89, 153, 163, 208, 202, 132, 50, 121, 227, 66, 113, 68, 206, 173, 94, 77, 89, 153, 163, 208,
        ]
    )

    func testParsesSpecialAddress0x0() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ZERO.longWith0x).toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ZERO.longWithout0x).toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ZERO.shortWith0x).toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ZERO.shortWithout0x).toString(), ADDRESS_ZERO.shortWith0x)
    }
    func testParsesSpecialAddress0x1() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ONE.longWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ONE.longWithout0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ONE.shortWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_ONE.shortWithout0x).toString(), ADDRESS_ONE.shortWith0x)
    }

    func testParsesSpecialAddress0x2() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TWO.longWith0x).toString(), ADDRESS_TWO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TWO.longWithout0x).toString(), ADDRESS_TWO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TWO.shortWith0x).toString(), ADDRESS_TWO.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TWO.shortWithout0x).toString(), ADDRESS_TWO.shortWith0x)
    }

    func testParsesSpecialAddress0x3() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_THREE.longWith0x).toString(), ADDRESS_THREE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_THREE.longWithout0x).toString(), ADDRESS_THREE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_THREE.shortWith0x).toString(), ADDRESS_THREE.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_THREE.shortWithout0x).toString(), ADDRESS_THREE.shortWith0x)
    }

    func testParsesSpecialAddress0x4() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_FOUR.longWith0x).toString(), ADDRESS_FOUR.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_FOUR.longWithout0x).toString(), ADDRESS_FOUR.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_FOUR.shortWith0x).toString(), ADDRESS_FOUR.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_FOUR.shortWithout0x).toString(), ADDRESS_FOUR.shortWith0x)
    }

    func testParsesSpecialAddress0xf() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F.longWith0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F.longWithout0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F.shortWith0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F.shortWithout0x).toString(), ADDRESS_F.shortWith0x)
    }

    func testParsesSpecialAddressWithPaddedShortForm0x0f() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F_PADDED_SHORT_FORM.shortWith0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_F_PADDED_SHORT_FORM.shortWithout0x).toString(), ADDRESS_F.shortWith0x)
    }

    func testParsesNonSpecialAddress0x10() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TEN.longWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TEN.longWithout0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TEN.shortWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_TEN.shortWithout0x).toString(), ADDRESS_TEN.longWith0x)
    }

    func testParsesNonSpecialAddress0xca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0() {
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_OTHER.longWith0x).toString(), ADDRESS_OTHER.longWith0x)
        XCTAssertEqual(try! AccountAddress.fromString(ADDRESS_OTHER.longWithout0x).toString(), ADDRESS_OTHER.longWith0x)
    }

    func testAccountAddressStaticSpecialAddresses() {
        XCTAssertEqual(AccountAddress.ZERO.toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(AccountAddress.ONE.toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(AccountAddress.TWO.toString(), ADDRESS_TWO.shortWith0x)
        XCTAssertEqual(AccountAddress.THREE.toString(), ADDRESS_THREE.shortWith0x)
        XCTAssertEqual(AccountAddress.FOUR.toString(), ADDRESS_FOUR.shortWith0x)
    }

    func testAccountAddressFromString() throws {
        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_ZERO.longWith0x).toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_ZERO.longWithout0x))
        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_ZERO.shortWith0x).toString(), ADDRESS_ZERO.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_ZERO.shortWithout0x))

        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_ONE.longWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_ONE.longWithout0x))
        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_ONE.shortWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_ONE.shortWithout0x))

       

        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_F.longWith0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_F.longWithout0x))
        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_F.shortWith0x).toString(), ADDRESS_F.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_F.shortWithout0x))

        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_F_PADDED_SHORT_FORM.shortWith0x))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_F_PADDED_SHORT_FORM.shortWithout0x))

        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_TEN.longWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_TEN.longWithout0x))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_TEN.shortWith0x))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_TEN.shortWithout0x))

        XCTAssertEqual(try AccountAddress.fromStringStrict(ADDRESS_OTHER.longWith0x).toString(), ADDRESS_OTHER.longWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(ADDRESS_OTHER.longWithout0x))
    }


    func testAccountAddressFrom() {
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_ONE.longWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_ONE.longWithout0x))
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_ONE.shortWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_ONE.shortWithout0x))
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_ONE.bytes).toString(), ADDRESS_ONE.shortWith0x)

        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_TEN.longWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_TEN.longWithout0x))
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_TEN.shortWith0x))
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_TEN.shortWithout0x))
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_TEN.bytes).toString(), ADDRESS_TEN.longWith0x)

        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_OTHER.longWith0x).toString(), ADDRESS_OTHER.longWith0x)
        XCTAssertThrowsError(try AccountAddress.fromStrict(ADDRESS_OTHER.longWithout0x))
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_OTHER.bytes).toString(), ADDRESS_OTHER.shortWith0x)

    }

    /*

describe("AccountAddress fromRelaxed", () => {
  it("parses special address: 0x1", () => {
    expect(AccountAddress.from(ADDRESS_ONE.longWith0x).toString()).toBe(ADDRESS_ONE.shortWith0x);
    expect(AccountAddress.from(ADDRESS_ONE.longWithout0x).toString()).toBe(ADDRESS_ONE.shortWith0x);
    expect(AccountAddress.from(ADDRESS_ONE.shortWith0x).toString()).toBe(ADDRESS_ONE.shortWith0x);
    expect(AccountAddress.from(ADDRESS_ONE.shortWithout0x).toString()).toBe(ADDRESS_ONE.shortWith0x);
    expect(AccountAddress.from(ADDRESS_ONE.bytes).toString()).toBe(ADDRESS_ONE.shortWith0x);
  });

  it("parses non-special address: 0x10", () => {
    expect(AccountAddress.from(ADDRESS_TEN.longWith0x).toString()).toBe(ADDRESS_TEN.longWith0x);
    expect(AccountAddress.from(ADDRESS_TEN.longWithout0x).toString()).toBe(ADDRESS_TEN.longWith0x);
    expect(AccountAddress.from(ADDRESS_TEN.shortWith0x).toString()).toBe(ADDRESS_TEN.longWith0x);
    expect(AccountAddress.from(ADDRESS_TEN.shortWithout0x).toString()).toBe(ADDRESS_TEN.longWith0x);
    expect(AccountAddress.from(ADDRESS_TEN.bytes).toString()).toBe(ADDRESS_TEN.longWith0x);
  });

  it("parses non-special address: 0xca843279e3427144cead5e4d5999a3d0ca843279e3427144cead5e4d5999a3d0", () => {
    expect(AccountAddress.from(ADDRESS_OTHER.longWith0x).toString()).toBe(ADDRESS_OTHER.longWith0x);
    expect(AccountAddress.from(ADDRESS_OTHER.longWithout0x).toString()).toBe(ADDRESS_OTHER.longWith0x);
    expect(AccountAddress.from(ADDRESS_OTHER.bytes).toString()).toBe(ADDRESS_OTHER.longWith0x);
  });
});

    */

    func testAccountAddressFromRelaxed() {
        XCTAssertEqual(try AccountAddress.from(ADDRESS_ONE.longWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_ONE.longWithout0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_ONE.shortWith0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_ONE.shortWithout0x).toString(), ADDRESS_ONE.shortWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_ONE.bytes).toString(), ADDRESS_ONE.shortWith0x)

        XCTAssertEqual(try AccountAddress.from(ADDRESS_TEN.longWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_TEN.longWithout0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_TEN.shortWith0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_TEN.shortWithout0x).toString(), ADDRESS_TEN.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_TEN.bytes).toString(), ADDRESS_TEN.longWith0x)

        XCTAssertEqual(try AccountAddress.from(ADDRESS_OTHER.longWith0x).toString(), ADDRESS_OTHER.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_OTHER.longWithout0x).toString(), ADDRESS_OTHER.longWith0x)
        XCTAssertEqual(try AccountAddress.from(ADDRESS_OTHER.bytes).toString(), ADDRESS_OTHER.longWith0x)
    }

    func testAccountAddressToUnit8Array() {
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_ONE.longWith0x).toUInt8Array(), ADDRESS_ONE.bytes)
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_TEN.longWith0x).toUInt8Array(), ADDRESS_TEN.bytes)
        XCTAssertEqual(try AccountAddress.fromStrict(ADDRESS_OTHER.longWith0x).toUInt8Array(), ADDRESS_OTHER.bytes)
    }

    func testAccountAddressToStringWithoutPrefix() throws {
        var addr = try AccountAddress.fromStringStrict(ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(addr.toStringWithoutPrefix(), ADDRESS_ZERO.shortWithout0x)

        addr = try AccountAddress.fromStringStrict(ADDRESS_TEN.longWith0x)
        XCTAssertEqual(addr.toStringWithoutPrefix(), ADDRESS_TEN.longWithout0x)
    }

    func testAccountAddressToStringLong() throws {
        var addr = try AccountAddress.fromStringStrict(ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(addr.toStringLong(), ADDRESS_ZERO.longWith0x)

        addr = try AccountAddress.fromStringStrict(ADDRESS_TEN.longWith0x)
        XCTAssertEqual(addr.toStringLong(), ADDRESS_TEN.longWith0x)
    }

    func testAccountAddressToStringLongWithoutPrefix() throws {
        var addr = try AccountAddress.fromStringStrict(ADDRESS_ZERO.shortWith0x)
        XCTAssertEqual(addr.toStringLongWithoutPrefix(), ADDRESS_ZERO.longWithout0x)

        addr = try AccountAddress.fromStringStrict(ADDRESS_TEN.longWith0x)
        XCTAssertEqual(addr.toStringLongWithoutPrefix(), ADDRESS_TEN.longWithout0x)
    }

    func testAccountAddressOtherParsing() throws {
        XCTAssertThrowsError(try AccountAddress.fromStringStrict("\(ADDRESS_ONE.longWith0x)1"))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict("0xxyz"))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict("0x"))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict(""))
        XCTAssertThrowsError(try AccountAddress.fromStringStrict("0za"))

        let result = AccountAddress.isValid("0x00\(ADDRESS_F.longWith0x)", strict: true)
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.invalidReason, AddressInvalidReason.tooLong)
        XCTAssertEqual(result.invalidReasonMessage, "Hex string is too long, must be 1 to 64 chars long, excluding the leading 0x.")

        let result2 = AccountAddress.isValid(ADDRESS_F.longWith0x, strict: true)
        XCTAssertTrue(result2.valid)
        XCTAssertNil(result2.invalidReason)
        XCTAssertNil(result2.invalidReasonMessage)

        let addressOne = try AccountAddress.fromString(ADDRESS_ONE.shortWith0x)
        let addressTwo = try AccountAddress.fromString(ADDRESS_ONE.shortWith0x)
        XCTAssertTrue(addressOne.equals(addressTwo))
    }

    func testAccountAddressSerializationAndDeserialization() throws {
        let serializeAndCheckEquality = { (address: AccountAddress) throws in
            let serializer = BcsSerializer()
            try serializer.serialize(value: address)
            XCTAssertEqual(serializer.getBytes(), address.toUInt8Array())
            XCTAssertEqual(serializer.toUInt8Array(), try address.bcsToBytes())
        }

        let address1 = try AccountAddress.fromString("0x0102030a0b0c")
        let address2 = try AccountAddress.fromString(ADDRESS_OTHER.longWith0x)
        let address3 = try AccountAddress.fromString(ADDRESS_ZERO.shortWithout0x)
        try serializeAndCheckEquality(address1)
        try serializeAndCheckEquality(address2)
        try serializeAndCheckEquality(address3)
        
        let bytes = ADDRESS_TEN.bytes
        let deserializer = BcsDeserializer(input: bytes)
        let deserializedAddress = try AccountAddress.deserialize(deserializer: deserializer)
        XCTAssertEqual(deserializedAddress.toUInt8Array(), bytes)

        let serializer = BcsSerializer()
        try serializer.serialize(value: address1)
        try serializer.serialize(value: address2)
        try serializer.serialize(value: address3)
        let deserializer2 = BcsDeserializer(input: serializer.toUInt8Array())
        let deserializedAddress1 = try AccountAddress.deserialize(deserializer: deserializer2)
        let deserializedAddress2 = try AccountAddress.deserialize(deserializer: deserializer2)
        var deserializedAddress3 = try AccountAddress.deserialize(deserializer: deserializer2)
        XCTAssertEqual(deserializedAddress1.toUInt8Array(), address1.toUInt8Array())
        XCTAssertEqual(deserializedAddress2.toUInt8Array(), address2.toUInt8Array())
        XCTAssertEqual(deserializedAddress3.toUInt8Array(), address3.toUInt8Array())

        let address = try AccountAddress.fromString("0x0102030a0b0c")
        let serializer3 = BcsSerializer()
        try serializer3.serialize(value: address)
        let deserializer3 = BcsDeserializer(input: serializer3.toUInt8Array())
        deserializedAddress3 = try AccountAddress.deserialize(deserializer: deserializer3)
        XCTAssertEqual(deserializedAddress3.toUInt8Array(), address.toUInt8Array())

        let bytes3: [UInt8] = [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 10, 11, 12,
        ]   
        XCTAssertEqual(deserializedAddress3.toUInt8Array(), bytes3)
    }
}