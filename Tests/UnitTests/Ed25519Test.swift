import XCTest
import Foundation
import BCS 
import Core 


class Ed25519PublicKeyTest: XCTestCase {
    func testShouldCreateTheInstanceCorrectlyWithoutError() throws {
        // Create from string
        let hexStr = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        let publicKey = try Ed25519PublicKey(hexStr)
        XCTAssertEqual(publicKey.toString(), hexStr)
        
        // Create from Uint8Array
        let hexUint8Array: [UInt8] = [
            1, 35, 69, 103, 137, 171, 205, 239, 1, 35, 69, 103, 137, 171, 205, 239, 1, 35, 69, 103, 137, 171, 205, 239, 1, 35,
            69, 103, 137, 171, 205, 239
        ]
        let publicKey2 = try Ed25519PublicKey(hexUint8Array)
        XCTAssertEqual(publicKey2.toUInt8Array(), hexUint8Array)
    }

    func testShouldThrowAnErrorWithInvalidHexInputLength() {
        let invalidHexInput = "0123456789abcdef" // Invalid length
        
        XCTAssertThrowsError(try Ed25519PublicKey(invalidHexInput)) { error in
            XCTAssertEqual(error as! PublicKeyError, PublicKeyError.invalidLength)
        }
    }

    func testShouldVerifyTheSignatureCorrectly() throws {
        let pubKey = try Ed25519PublicKey(Ed25519.publicKey)
        let signature = try Ed25519Signature(Ed25519.signatureHex)
        
        // Verify with correct signed message
        XCTAssertTrue(try pubKey.verifySignature(message: Ed25519.messageEncoded, signature: signature))
        
        // // Verify with incorrect signed message
        let incorrectSignedMessage = "0xc5de9e40ac00b371cd83b1c197fa5b665b7449b33cd3cdd305bb78222e06a671a49625ab9aea8a039d4bb70e275768084d62b094bc1b31964f2357b7c1af7e0a"
        let invalidSignature = try Ed25519Signature(incorrectSignedMessage)
        XCTAssertFalse(try pubKey.verifySignature(message: Ed25519.messageEncoded, signature: invalidSignature))
    }

    func testShouldFailMalleableSignatures() throws {
        // Here we make a signature exactly with the L
        let signature = try Ed25519Signature(
            // eslint-disable-next-line max-len
            "0x0000000000000000000000000000000000000000000000000000000000000000edd3f55c1a631258d69cf7a2def9de1400000000000000000000000000000010")
        XCTAssertFalse(signature.isCanonicalSignature())

        // We now check with L + 1
        let signature2 = try Ed25519Signature(
            // eslint-disable-next-line max-len
            "0x0000000000000000000000000000000000000000000000000000000000000000edd3f55c1a631258d69cf7a2def9de1400000000000000000000000000000011")
        XCTAssertFalse(signature2.isCanonicalSignature())
    }

    func testShouldSerializeCorrectly() throws {
        let publicKey = try Ed25519PublicKey(Ed25519.publicKey)
        let serializer = BcsSerializer()
        try publicKey.serialize(serializer: serializer)

        let expectedUint8Array: [UInt8] = [
            32, 222, 25, 229, 209, 136, 12, 172, 135, 213, 116, 132, 206, 158, 210, 232, 76, 240, 249, 89, 159, 18, 231, 204,
            58, 82, 228, 231, 101, 122, 118, 63, 44
        ]
        XCTAssertEqual(serializer.getBytes(), expectedUint8Array)
    }

    func testShouldDeserializeCorrectly() throws {
        let serializedPublicKey: [UInt8] = [
            32, 222, 25, 229, 209, 136, 12, 172, 135, 213, 116, 132, 206, 158, 210, 232, 76, 240, 249, 89, 159, 18, 231, 204,
            58, 82, 228, 231, 101, 122, 118, 63, 44
        ]
        let deserializer = BcsDeserializer(input: serializedPublicKey)

        let publicKey = try Ed25519PublicKey.deserialize(deserializer: deserializer)

        XCTAssertEqual(publicKey.toString(), Ed25519.publicKey)
    }

    func testSerializeAndDeserializeCorrectly() throws {
        let hexInput = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        let publicKey = try Ed25519PublicKey(hexInput)
        let serializer = BcsSerializer()
        try publicKey.serialize(serializer: serializer)

        let deserializer = BcsDeserializer(input: serializer.getBytes())
        let deserializedPublicKey = try Ed25519PublicKey.deserialize(deserializer: deserializer)

        XCTAssertEqual(deserializedPublicKey, publicKey)
    }
}

// MARK: - PrivateKey
class Ed25519PrivateKeyTest: XCTestCase {
  func testShouldCreateTheInstanceCorrectlyWithoutError() throws {
        // Create from string
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        XCTAssertEqual(privateKey.toString(), Ed25519.privateKey)

        // Create from Uint8Array
        let hexUint8Array: [UInt8] = [
            197, 51, 140, 210, 81, 194, 45, 170, 140, 156, 156, 201, 79, 73, 140, 200, 165, 199, 225, 210, 231, 82, 135,
            165, 221, 169, 16, 150, 254, 100, 239, 165
        ]
        let privateKey2 = try Ed25519PrivateKey(hexUint8Array)
        XCTAssertEqual(privateKey2.toUInt8Array(), hexUint8Array)
    }

    func testShouldThrowAnErrorWithInvalidHexInputLength() {
        let invalidHexInput = "0123456789abcdef" // Invalid length
        
        XCTAssertThrowsError(try Ed25519PrivateKey(invalidHexInput)) { error in
            XCTAssertEqual(error as! PrivateKeyError, PrivateKeyError.invalidLength)
        }
    }


    func testShouldSerializeCorrectly() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let serializer = BcsSerializer()
        try privateKey.serialize(serializer: serializer)

        let expectedUint8Array: [UInt8] = [
            32, 197, 51, 140, 210, 81, 194, 45, 170, 140, 156, 156, 201, 79, 73, 140, 200, 165, 199, 225, 210, 231, 82, 135,
            165, 221, 169, 16, 150, 254, 100, 239, 165,
        ]
        XCTAssertEqual(serializer.getBytes(), expectedUint8Array)
    }

    func testShouldDeserializeCorrectly() throws {
        let serializedPrivateKey: [UInt8] = [
            32, 197, 51, 140, 210, 81, 194, 45, 170, 140, 156, 156, 201, 79, 73, 140, 200, 165, 199, 225, 210, 231, 82, 135,
            165, 221, 169, 16, 150, 254, 100, 239, 165,
        ]
        let deserializer = BcsDeserializer(input: serializedPrivateKey)

        let privateKey = try Ed25519PrivateKey.deserialize(deserializer: deserializer)

        XCTAssertEqual(privateKey.toString(), Ed25519.privateKey)
    }

    func testShouldSerializeAndDeserializeCorrectly() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let serializer = BcsSerializer()
        try privateKey.serialize(serializer: serializer)

        let deserializer = BcsDeserializer(input: serializer.getBytes())
        let deserializedPrivateKey = try Ed25519PrivateKey.deserialize(deserializer: deserializer)

        XCTAssertEqual(deserializedPrivateKey, privateKey)
    }

    func testShouldGenerateRandomPrivateKeyCorrectly() {
        // Make sure it generate new PrivateKey successfully
        let privateKey =  Ed25519PrivateKey.generate()
        XCTAssertEqual(privateKey.toUInt8Array().count, Ed25519PrivateKey.LENGTH)

        // Make sure it generate different private keys
        let anotherPrivateKey = Ed25519PrivateKey.generate()
        XCTAssertNotEqual(anotherPrivateKey.toString(), privateKey.toString())
    }

    func testShouldDeriveThePublicKeyCorrectly() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let publicKey = try privateKey.publicKey()
        XCTAssertEqual(publicKey.toString(), Ed25519.publicKey)
    }
    
    func testShouldPreventAnInvalidBip44Path() {
        let mnemonic = Wallet.mnemonic
        let path = "1234"
        XCTAssertThrowsError(try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)) { error in
            XCTAssertEqual(error as! PrivateKeyError, PrivateKeyError.invalidDerivationPath(path))
        }
    }

    func testShouldDeriveFromPathAndMnemonic() throws {
        let mnemonic = Wallet.mnemonic
        let path = Wallet.path
        let privateKey = Wallet.privateKey
        let key = try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)
        XCTAssertEqual(key.toString(), privateKey)
    }

    // MARK: - AIP-80 Tests
    func testShouldFormatPrivateKeyToAIP80() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let aip80String = try privateKey.toAIP80String()

        // Verify the format is correct
        XCTAssertTrue(aip80String.hasPrefix("ed25519-priv-"))

        // Extract the hex part and verify it matches
        let components = aip80String.components(separatedBy: "-")
        XCTAssertEqual(components.count, 3)
        XCTAssertEqual(components[0], "ed25519")
        XCTAssertEqual(components[1], "priv")

        // Verify the hex part matches the original key (without 0x prefix)
        let expectedHex = privateKey.toString().replacingOccurrences(of: "0x", with: "")
        XCTAssertEqual(components[2], expectedHex)
    }

    func testShouldParseAIP80FormattedPrivateKey() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let aip80String = try privateKey.toAIP80String()

        // Create a new private key from the AIP-80 string
        let parsedPrivateKey = try Ed25519PrivateKey(aip80String)

        // Verify they are equal
        XCTAssertEqual(parsedPrivateKey.toString(), privateKey.toString())
        XCTAssertEqual(parsedPrivateKey.toUInt8Array(), privateKey.toUInt8Array())
    }

    func testShouldParseNonAIP80PrivateKeyWithWarning() throws {
        // This should work but should print a warning (we can't test the warning in unit tests easily)
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        XCTAssertEqual(privateKey.toString(), Ed25519.privateKey)
    }

    func testShouldFormatAIP80StringToAIP80() throws {
        // Formatting an already AIP-80 formatted string should return the same format
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let aip80String1 = try privateKey.toAIP80String()

        // Create a new private key from the AIP-80 string and format it again
        let privateKey2 = try Ed25519PrivateKey(aip80String1)
        let aip80String2 = try privateKey2.toAIP80String()

        // Both should be equal
        XCTAssertEqual(aip80String1, aip80String2)
    }

    func testShouldParseByteArrayToAIP80() throws {
        let hexUint8Array: [UInt8] = [
            197, 51, 140, 210, 81, 194, 45, 170, 140, 156, 156, 201, 79, 73, 140, 200, 165, 199, 225, 210, 231, 82, 135,
            165, 221, 169, 16, 150, 254, 100, 239, 165
        ]

        let privateKey = try Ed25519PrivateKey(hexUint8Array)
        let aip80String = try privateKey.toAIP80String()

        // Verify the format is correct
        XCTAssertTrue(aip80String.hasPrefix("ed25519-priv-"))

        // Parse it back and verify
        let parsedPrivateKey = try Ed25519PrivateKey(aip80String)
        XCTAssertEqual(parsedPrivateKey.toUInt8Array(), hexUint8Array)
    }

    func testShouldSignAndVerifyWithAIP80FormattedKey() throws {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let aip80String = try privateKey.toAIP80String()

        // Create a new private key from the AIP-80 string
        let aip80PrivateKey = try Ed25519PrivateKey(aip80String)

        // Sign a message with both keys
        let message = "test message"
        let signature1 = try privateKey.sign(message: message)
        let signature2 = try aip80PrivateKey.sign(message: message)

        // Both public keys should be equal
        let publicKey1 = try privateKey.publicKey() as! Ed25519PublicKey
        let publicKey2 = try aip80PrivateKey.publicKey() as! Ed25519PublicKey
        XCTAssertEqual(publicKey1.toString(), publicKey2.toString())

        // Both signatures should verify with both public keys
        XCTAssertTrue(try publicKey1.verifySignature(message: message, signature: signature1))
        XCTAssertTrue(try publicKey2.verifySignature(message: message, signature: signature2))
    }
}
    


class Ed25519SignatureTest: XCTestCase {

    func testShouldCreateAnInstanceCorrectlyWithoutError() throws {
        // Create from string
        let signature = try Ed25519Signature(Ed25519.signatureHex)
        XCTAssertEqual(signature.toString(), Ed25519.signatureHex)

        // Create from Uint8Array
        let signatureValue: [UInt8] = Array(repeating: 0, count: Ed25519Signature.LENGTH)
        let signature2 = try Ed25519Signature(signatureValue)
        XCTAssertEqual(signature2.toUInt8Array(), signatureValue)
    }

    func testShouldThrowAnErrorWithInvalidValueLength() {
        let invalidSignatureValue: [UInt8] = Array(repeating: 0, count: Ed25519Signature.LENGTH - 1) // Invalid length
        XCTAssertThrowsError(try Ed25519Signature(invalidSignatureValue)) { error in
            XCTAssertEqual(error as! SignatureError, SignatureError.invalidLength)
        }
    }

    func testShouldSerializeCorrectly() throws {
        let signature = try Ed25519Signature(Ed25519.signatureHex)
        let serializer = BcsSerializer()
        try signature.serialize(serializer: serializer)
        let expectedUint8Array: [UInt8] = [
            64, 158, 101, 61, 86, 160, 146, 71, 87, 11, 177, 116, 163, 137, 232, 91, 146, 38, 171, 213, 196, 3, 234, 108, 80,
            75, 56, 102, 38, 161, 69, 21, 140, 212, 239, 214, 111, 197, 224, 113, 192, 225, 149, 56, 169, 106, 5, 221, 189,
            162, 77, 60, 81, 225, 230, 169, 218, 204, 107, 177, 206, 119, 92, 206, 7,
        ]
        XCTAssertEqual(serializer.getBytes(), expectedUint8Array)
    }

    func testShouldDeserializeCorrectly() throws {
        let serializedSignature: [UInt8] = [
            64, 158, 101, 61, 86, 160, 146, 71, 87, 11, 177, 116, 163, 137, 232, 91, 146, 38, 171, 213, 196, 3, 234, 108, 80,
            75, 56, 102, 38, 161, 69, 21, 140, 212, 239, 214, 111, 197, 224, 113, 192, 225, 149, 56, 169, 106, 5, 221, 189,
            162, 77, 60, 81, 225, 230, 169, 218, 204, 107, 177, 206, 119, 92, 206, 7,
        ]

        let deserializer = BcsDeserializer(input: serializedSignature)
        let signature = try Ed25519Signature.deserialize(deserializer: deserializer)
        XCTAssertEqual(signature.toString(), Ed25519.signatureHex)
    }

    func testShouldSerializeAndDeserializeCorrectly() throws {
        let signature = try Ed25519Signature(Ed25519.signatureHex)
        let serializer = BcsSerializer()
        try signature.serialize(serializer: serializer)

        let deserializer = BcsDeserializer(input: serializer.getBytes())
        let deserializedSignature = try Ed25519Signature.deserialize(deserializer: deserializer)

        XCTAssertEqual(deserializedSignature, signature)
    }
}