import Types
import XCTest
import Core

class HexTest: XCTestCase {
    let mockHex = (
        withoutPrefix: "007711b4d0",
        withPrefix: "0x007711b4d0",
        bytes: [UInt8]([0, 119, 17, 180, 208]))
    
    func testCreatesAnewHexInstanceFromBytes() {
        let hex = Hex(data: mockHex.bytes)
        XCTAssertEqual(hex.toUInt8Array(), mockHex.bytes)
    }

    func testCreatesAnewHexInstanceFromString() {
        let hex = try! Hex.fromHexString(mockHex.withPrefix)
        XCTAssertEqual(hex.toString(), mockHex.withPrefix)
    }
   
    func testConvertsHexBytesInputIntoHexData() {
        let hex = Hex(data: mockHex.bytes)
        XCTAssertEqual(hex.toUInt8Array(), mockHex.bytes)
    }

    func testAcceptsHexStringInputWithoutPrefix() {
        let hex = try! Hex.fromHexString(mockHex.withoutPrefix)
        XCTAssertEqual(hex.toUInt8Array(), mockHex.bytes)
    }
   
    func testAcceptsHexStringInputWithPrefix() {
        let hex = try! Hex.fromHexString(mockHex.withPrefix)
        XCTAssertEqual(hex.toUInt8Array(), mockHex.bytes)
    }

    func testConvertsHexStringToBytes() {
        let hex = try! Hex.fromHexString(mockHex.withPrefix)
        XCTAssertEqual(hex.toUInt8Array(), mockHex.bytes)
    }

    func testConvertsHexBytesToString() {
        let hex = Hex(data: mockHex.bytes)
        XCTAssertEqual(hex.toString(), mockHex.withPrefix)
    }

   
    func testConvertsHexBytesToStringWithoutPrefix() throws {
        let hex = try Hex.fromHexInput(mockHex.bytes)
        XCTAssertEqual(hex.toStringWithoutPrefix(), mockHex.withoutPrefix)
    }

    func testThrowsWhenParsingInvalidHexChar() {
        XCTAssertThrowsError(try Hex.fromHexString("0xzyzz"))
        // 'Hex string contains invalid hex characters: hex string expected, got non-hex character "zy" at index 0',

    }

    func testThrowsWhenParsingHexOfLengthZero() {
        XCTAssertThrowsError(try Hex.fromHexString("0x"))
        // 'Hex string is too short, must be at least 1 char long, excluding the optional leading 0x.'
        XCTAssertThrowsError(try Hex.fromHexString(""))
        // 'Hex string is too short, must be at least 1 char long, excluding the optional leading 0x.'
    }

    func testThrowsWhenParsingHexOfInvalidLength() {
        XCTAssertThrowsError(try Hex.fromHexString("0x1"))
        // 'Hex string must be an even number of hex characters.'
    }

    func testThrowsWhenParsingHexOfInvalidLengthWithoutPrefix() {
        XCTAssertThrowsError(try Hex.fromHexString("1"))
        // 'Hex string must be an even number of hex characters.'
    }

    func testIsVaildReturnsTrueWhenParsingValidString() {
        let result = Hex.isValid("0x11aabb")
        XCTAssertTrue(result.valid)
        XCTAssertNil(result.invalidReason)
        XCTAssertNil(result.invalidReasonMessage)
    }

    func testIsVaildReturnsFalseWhenParsingHexOfInvalidLength() {
        let result = Hex.isValid("0xa")
        XCTAssertFalse(result.valid)
        XCTAssertEqual(result.invalidReason, HexInvalidReason.invalidLength)
        XCTAssertEqual(result.invalidReasonMessage, "Hex string must be an even number of hex characters.")
    }

    func testComparesEqualityWithEqualsAsExpected() {
        let hexOne = try! Hex.fromHexString("0x11")
        let hexTwo = try! Hex.fromHexString("0x11")
        XCTAssertTrue(hexOne.equals(hexTwo))
    }

}