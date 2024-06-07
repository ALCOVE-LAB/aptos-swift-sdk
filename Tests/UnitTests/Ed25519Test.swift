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
        XCTAssertThrowsError(try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonics: mnemonic)) { error in
            XCTAssertEqual(error as! PrivateKeyError, PrivateKeyError.invalidDerivationPath(path))
        }
    }

    func testShouldDeriveFromPathAndMnemonic() throws {
        let mnemonic = Wallet.mnemonic
        let path = Wallet.path
        let privateKey = Wallet.privateKey
        let key = try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonics: mnemonic)
        XCTAssertEqual(key.toString(), privateKey)
    }
}
    

