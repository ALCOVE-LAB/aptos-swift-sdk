
import XCTest
import Foundation
import Core
import BCS

class AuthenticationKeyTest: XCTestCase {
    func testCreateInstanceWithSaveHexInputCorrectly() {
        let authKey = try! AuthenticationKey(Ed25519.authKey)
        XCTAssertEqual(authKey.data.toString(), Ed25519.authKey)
    }

    func testThrowErrorWithInvalidHexInputLength() {
        let invalidHexInput = "0123456789abcdef"
        XCTAssertThrowsError(try AuthenticationKey(invalidHexInput)) { error in
            XCTAssertEqual(error as! AuthenticationKeyError, AuthenticationKeyError.invalidLength)
        }
    }

    func testDeriveAccountAddressFromAuthenticationKey() {
        let authKey = try! AuthenticationKey(Ed25519.authKey)
        let accountAddress = try! authKey.derivedAddress()
        XCTAssertEqual(accountAddress.toString(), Ed25519.authKey)
    }

    func testSerializeAuthenticationKeyCorrectly() {
        let authKey = try! AuthenticationKey(Ed25519.authKey)
        let serializer = BcsSerializer()
        try! authKey.serialize(serializer: serializer)
        let expected: [UInt8] = [
            151, 140, 33, 57, 144, 196, 131, 61, 247, 21, 72, 223, 124, 228, 157, 84, 199, 89, 214, 182, 217, 50, 222, 34,
            178, 77, 86, 6, 11, 122, 242, 170
        ]
        XCTAssertEqual(serializer.getBytes(), expected)
    }

    func testDeserializeAuthenticationKeyCorrectly() {
        let serializedAuthKey: [UInt8] = [
            151, 140, 33, 57, 144, 196, 131, 61, 247, 21, 72, 223, 124, 228, 157, 84, 199, 89, 214, 182, 217, 50, 222, 34,
            178, 77, 86, 6, 11, 122, 242, 170
        ]
        let deserializer = BcsDeserializer(input: serializedAuthKey)
        let authKeyDeserialized = try! AuthenticationKey.deserialize(from: deserializer)
        XCTAssertEqual(authKeyDeserialized.data.toString(), Ed25519.authKey)
    }

    func testShouldCreateAuthenticationKeyFromEd25519PublicKey() throws {
        let publicKey = try Ed25519PublicKey(Ed25519.publicKey)
        let authKey = try publicKey.authKey()
        XCTAssertEqual(authKey.data.toString(), Ed25519.authKey)
    }

    func testShouldCreateAuthenticationKeyFromMultiPublicKey() throws {

        let edPksArray = try MultiEd25519PublicKey(
          publicKeys: MultiEd25519.publicKeys.map({ try Ed25519PublicKey($0)}),
          threshold: MultiEd25519.threshold)
        let authKey = try edPksArray.authKey()
        XCTAssertEqual(authKey.data.toString(), "0xa81cfac3df59920593ff417b45fc347ead3d88f8e25112c0488d34d7c9eb20af")
    }
}
