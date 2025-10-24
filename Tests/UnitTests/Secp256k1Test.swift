import XCTest
import Foundation
import BCS 
import Core 
import secp256k1
import Types 

class Secp256k1PublicKeyTest: XCTestCase {

    func testShouldCreateTheInstanceCorrectlyWithoutError() throws {
        // Create from string
        let publicKey = try Secp256k1PublicKey(Secp256k1.publicKey)
        XCTAssertEqual(publicKey.toString(), Secp256k1.publicKey)
        // Create from Uint8Array
        let publicData = try secp256k1.Signing.PrivateKey(format: .uncompressed).publicKey.dataRepresentation
        let publicKey2 = try Secp256k1PublicKey(publicData)
        XCTAssertEqual(publicKey2.toUInt8Array(), Array(publicData))
    }

    func testShouldThrowAnErrorWithInvalidHexInputLength() throws {
        let invalidHexInput = "0123456789abcdef" // Invalid length
        XCTAssertThrowsError(try Secp256k1PublicKey(invalidHexInput)) { error in
            XCTAssertEqual(error as! PublicKeyError, PublicKeyError.invalidLength)
        }
    }

    func testShouldVerifyTheSignatureCorrectly() throws {
        let pubKey = try Secp256k1PublicKey(Secp256k1.publicKey)
        let signature = try Secp256k1Signature(Secp256k1.signatureHex)
        
        // Convert message to hex
        let hexMsg = try Hex.fromHexString(Secp256k1.messageEncoded)

        // Verify with correct signed message"
        XCTAssertTrue(try pubKey.verifySignature(message: hexMsg.toUInt8Array(), signature: signature))

        // Verify with incorrect signed message
        let incorrectSignedMessage = "0xc5de9e40ac00b371cd83b1c197fa5b665b7449b33cd3cdd305bb78222e06a671a49625ab9aea8a039d4bb70e275768084d62b094bc1b31964f2357b7c1af7e0a"
        let invalidSignature = try Secp256k1Signature(incorrectSignedMessage)
        XCTAssertFalse(try pubKey.verifySignature(message: Secp256k1.messageEncoded, signature: invalidSignature))
    }

    func testShouldSerializeCorrectly() throws {
        let publicKey = try Secp256k1PublicKey(Secp256k1.publicKey)
        let serializer = BcsSerializer()
        try publicKey.serialize(serializer: serializer)
        let serialized = try Hex.fromHexInput(serializer.toUInt8Array()).toString()
        let  expected = "0x4104acdd16651b839c24665b7e2033b55225f384554949fef46c397b5275f37f6ee95554d70fb5d9f93c5831ebf695c7206e7477ce708f03ae9bb2862dc6c9e033ea"
        XCTAssertEqual(serialized, expected)
    }


    func testShouldDeserializeCorrectly() throws {
        let serializedPublicKeyStr = "0x4104acdd16651b839c24665b7e2033b55225f384554949fef46c397b5275f37f6ee95554d70fb5d9f93c5831ebf695c7206e7477ce708f03ae9bb2862dc6c9e033ea"
        let serializedPublicKey = try Hex.fromHexString(serializedPublicKeyStr).toUInt8Array()
        let deserializer = BcsDeserializer(input: serializedPublicKey)
        let publicKey = try Secp256k1PublicKey.deserialize(deserializer: deserializer)
        XCTAssertEqual(publicKey.toString(), Secp256k1.publicKey)
    }
}

class Secp256k1PrivateKeyTest: XCTestCase {

  func testShouldCreateTheInstanceCorrectlyWithoutError() throws {
    // Create from string
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    XCTAssertEqual(privateKey.toString(), Secp256k1.privateKey)

    // Create from Uint8Array
    let hexUint8Array = try Hex.fromHexString(Secp256k1.privateKey).toUInt8Array()
    let privateKey2 = try Secp256k1PrivateKey(hexUint8Array)
    XCTAssertEqual(privateKey2.toString(), try Hex.fromHexInput(hexUint8Array).toString())

    let privateData = try secp256k1.Signing.PrivateKey(format: .uncompressed).dataRepresentation
    let privateKey3 = try Secp256k1PrivateKey(privateData)
    XCTAssertEqual(privateKey3.toUInt8Array(), Array(privateData))
  }

  func testShouldSignTheMessageCorrectly() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let signedMessage = try privateKey.sign(message: Secp256k1.messageEncoded)
    XCTAssertEqual(signedMessage.toString(), Secp256k1.signatureHex)
  }

  func testShouldThrowAnErrorWithInvalidHexInputLength() throws {
    let invalidHexInput = "0123456789abcdef" // Invalid length
    XCTAssertThrowsError(try Secp256k1PrivateKey(invalidHexInput)) { error in
        XCTAssertEqual(error as! PrivateKeyError, PrivateKeyError.invalidLength)
    }
  }

  func testShouldSerializeCorrectly() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let serializer = BcsSerializer()
    try privateKey.serialize(serializer: serializer)
    let serialized = try Hex.fromHexInput(serializer.toUInt8Array()).toString()
    let expected = "0x20d107155adf816a0a94c6db3c9489c13ad8a1eda7ada2e558ba3bfa47c020347e"
    XCTAssertEqual(serialized, expected)
  }

  func testShouldDeserializeCorrectly() throws {
    let serializedPrivateKeyStr = "0x20d107155adf816a0a94c6db3c9489c13ad8a1eda7ada2e558ba3bfa47c020347e"
    let serializedPrivateKey = try Hex.fromHexString(serializedPrivateKeyStr).toUInt8Array()
    let deserializer = BcsDeserializer(input: serializedPrivateKey)
    let privateKey = try Secp256k1PrivateKey.deserialize(deserializer: deserializer)
    XCTAssertEqual(privateKey.toString(), Secp256k1.privateKey)
  }

  func testShouldSerializeAndDeserializeCorrectly() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let serializer = BcsSerializer()
    try privateKey.serialize(serializer: serializer)

    let deserializer = BcsDeserializer(input: serializer.toUInt8Array())
    let deserializedPrivateKey = try Secp256k1PrivateKey.deserialize(deserializer: deserializer)
    XCTAssertEqual(deserializedPrivateKey.toString(), privateKey.toString())
  }

  func testShouldPreventAnInvaildBip44Path() throws {
    let mnemonic = Secp256k1Wallet.mnemonic
    let path = "1234"
    XCTAssertThrowsError(try Secp256k1PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)) { error in
        XCTAssertEqual(error as! PrivateKeyError, PrivateKeyError.invalidBIP44Path(path))
    }
  }

  func testShouldDeriveFromPathAndMnemonic() throws {
    let mnemonic = Secp256k1Wallet.mnemonic
    let path = Secp256k1Wallet.path
    let privateKey = Secp256k1Wallet.privateKey
    let key = try Secp256k1PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)
    XCTAssertEqual(key.toString(), privateKey)
  }

  // MARK: - AIP-80 Tests
  func testShouldFormatPrivateKeyToAIP80() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let aip80String = try privateKey.toAIP80String()

    // Verify the format is correct
    XCTAssertTrue(aip80String.hasPrefix("secp256k1-priv-"))

    // Extract the hex part and verify it matches
    let components = aip80String.components(separatedBy: "-")
    XCTAssertEqual(components.count, 3)
    XCTAssertEqual(components[0], "secp256k1")
    XCTAssertEqual(components[1], "priv")

    // Verify the hex part matches the original key (without 0x prefix)
    let expectedHex = privateKey.toString().replacingOccurrences(of: "0x", with: "")
    XCTAssertEqual(components[2], expectedHex)
  }

  func testShouldParseAIP80FormattedPrivateKey() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let aip80String = try privateKey.toAIP80String()

    // Create a new private key from the AIP-80 string
    let parsedPrivateKey = try Secp256k1PrivateKey(aip80String)

    // Verify they are equal
    XCTAssertEqual(parsedPrivateKey.toString(), privateKey.toString())
    XCTAssertEqual(parsedPrivateKey.toUInt8Array(), privateKey.toUInt8Array())
  }

  func testShouldFormatAIP80StringToAIP80() throws {
    // Formatting an already AIP-80 formatted string should return the same format
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let aip80String1 = try privateKey.toAIP80String()

    // Create a new private key from the AIP-80 string and format it again
    let privateKey2 = try Secp256k1PrivateKey(aip80String1)
    let aip80String2 = try privateKey2.toAIP80String()

    // Both should be equal
    XCTAssertEqual(aip80String1, aip80String2)
  }

  func testShouldSignAndVerifyWithAIP80FormattedKey() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let aip80String = try privateKey.toAIP80String()

    // Create a new private key from the AIP-80 string
    let aip80PrivateKey = try Secp256k1PrivateKey(aip80String)

    // Sign a message with both keys
    let message = "test message"
    let signature1 = try privateKey.sign(message: message)
    let signature2 = try aip80PrivateKey.sign(message: message)

    // Both public keys should be equal
    let publicKey1 = try privateKey.publicKey() as! Secp256k1PublicKey
    let publicKey2 = try aip80PrivateKey.publicKey() as! Secp256k1PublicKey
    XCTAssertEqual(publicKey1.toString(), publicKey2.toString())

    // Both signatures should verify with both public keys
    XCTAssertTrue(try publicKey1.verifySignature(message: message, signature: signature1))
    XCTAssertTrue(try publicKey2.verifySignature(message: message, signature: signature2))
  }
}

class Secp256k1SignatureTest: XCTestCase {
  
  func testShouldCreateAnInstanceCorrectlyWithoutError() throws {
    // Create from string
    let signature = try Secp256k1Signature(Secp256k1.signatureHex)
    XCTAssertEqual(signature.toString(), Secp256k1.signatureHex)

    // Create from Uint8Array
    let signatureValue = [UInt8](unsafeUninitializedCapacity: Secp256k1Signature.LENGTH, initializingWith: { buffer, count in
      for i in 0..<Secp256k1Signature.LENGTH {
        buffer[i] = UInt8(i)
      }
      count = Secp256k1Signature.LENGTH
    } )

    let signature2 = try Secp256k1Signature(signatureValue)
    XCTAssertEqual(signature2.toUInt8Array(), signatureValue)
  }

  func testShouldThrowAnErrorWithInvaildValueLength() throws {
    let invalidSignatureValue = [UInt8](repeating: 0, count: Secp256k1Signature.LENGTH - 1) // Invalid length
    XCTAssertThrowsError(try Secp256k1Signature(invalidSignatureValue)) { error in
        XCTAssertEqual(error as! SignatureError, SignatureError.invalidLength)
    }
  }

  func testShouldSerializeCorrectly() throws {
    let signature = try Secp256k1Signature(Secp256k1.signatureHex)
    let serializer = BcsSerializer()
    try signature.serialize(serializer: serializer)
    let serialized = try Hex.fromHexInput(serializer.toUInt8Array()).toString()
    let expected = "0x40d0d634e843b61339473b028105930ace022980708b2855954b977da09df84a770c0b68c29c8ca1b5409a5085b0ec263be80e433c83fcf6debb82f3447e71edca"
    XCTAssertEqual(serialized, expected)
  }

  func testShouldDeserializeCorrectly() throws {
    let serializedSignatureStr = "0x40d0d634e843b61339473b028105930ace022980708b2855954b977da09df84a770c0b68c29c8ca1b5409a5085b0ec263be80e433c83fcf6debb82f3447e71edca"
    let serializedSignature = try Hex.fromHexString(serializedSignatureStr).toUInt8Array()
    let deserializer = BcsDeserializer(input: serializedSignature)
    let signature = try Secp256k1Signature.deserialize(deserializer: deserializer)
    XCTAssertEqual(signature.toString(), Secp256k1.signatureHex)
  }

}
