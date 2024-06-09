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

        //Verify with incorrect signed message
        // let incorrectSignedMessage = "0xc5de9e40ac00b371cd83b1c197fa5b665b7449b33cd3cdd305bb78222e06a671a49625ab9aea8a039d4bb70e275768084d62b094bc1b31964f2357b7c1af7e0a"
        // let invalidSignature = try Secp256k1Signature(incorrectSignedMessage)
        // XCTAssertFalse(try pubKey.verifySignature(message: Secp256k1.messageEncoded, signature: invalidSignature))
    }

    /*

  it("should verify the signature correctly", () => {
    const pubKey = new Secp256k1PublicKey(secp256k1TestObject.publicKey);
    const signature = new Secp256k1Signature(secp256k1TestObject.signatureHex);

    // Convert message to hex
    const hexMsg = Hex.fromHexString(secp256k1TestObject.messageEncoded);

    // Verify with correct signed message
    expect(pubKey.verifySignature({ message: hexMsg.toUint8Array(), signature })).toBe(true);

    // Verify with incorrect signed message
    const incorrectSignedMessage =
      "0xc5de9e40ac00b371cd83b1c197fa5b665b7449b33cd3cdd305bb78222e06a671a49625ab9aea8a039d4bb70e275768084d62b094bc1b31964f2357b7c1af7e0a";
    const invalidSignature = new Secp256k1Signature(incorrectSignedMessage);
    expect(
      pubKey.verifySignature({
        message: secp256k1TestObject.messageEncoded,
        signature: invalidSignature,
      }),
    ).toBe(false);
  });

  it("should serialize correctly", () => {
    const publicKey = new Secp256k1PublicKey(secp256k1TestObject.publicKey);
    const serializer = new Serializer();
    publicKey.serialize(serializer);

    const serialized = Hex.fromHexInput(serializer.toUint8Array()).toString();
    const expected =
      "0x4104acdd16651b839c24665b7e2033b55225f384554949fef46c397b5275f37f6ee95554d70fb5d9f93c5831ebf695c7206e7477ce708f03ae9bb2862dc6c9e033ea";
    expect(serialized).toEqual(expected);
  });

  it("should deserialize correctly", () => {
    const serializedPublicKeyStr =
      "0x4104acdd16651b839c24665b7e2033b55225f384554949fef46c397b5275f37f6ee95554d70fb5d9f93c5831ebf695c7206e7477ce708f03ae9bb2862dc6c9e033ea";
    const serializedPublicKey = Hex.fromHexString(serializedPublicKeyStr).toUint8Array();
    const deserializer = new Deserializer(serializedPublicKey);
    const publicKey = Secp256k1PublicKey.deserialize(deserializer);

    expect(publicKey.toString()).toEqual(secp256k1TestObject.publicKey);
  });
    */
}

class Secp256k1PrivateKeyTest: XCTestCase {

  func testShouldSignTheMessageCorrectly() throws {
    let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
    let signedMessage = try privateKey.sign(message: Secp256k1.messageEncoded)
    XCTAssertEqual(signedMessage.toString(), Secp256k1.signatureHex)
  }

}

class Secp256k1SignatureTest: XCTestCase {

}
