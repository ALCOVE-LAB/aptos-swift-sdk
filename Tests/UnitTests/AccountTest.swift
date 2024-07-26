import XCTest
import Core
import Types


class AccountTest: XCTestCase {
    func testGenerate() {
        // Account with Legacy Ed25519 scheme
        let edAccount = Account.generate()
        XCTAssertTrue(edAccount.publicKey is Ed25519PublicKey)
        XCTAssertEqual(edAccount.signingScheme, SigningScheme.ed25519)
        
        // Account with SingleKey Ed25519 scheme
        let edAccount2 = Account.generate(.init(scheme: .ed25519, legacy: false))
        XCTAssertTrue(edAccount2 is Account.SingleKeyAccount)
        XCTAssertTrue(edAccount2.publicKey is AnyPublicKey)
        XCTAssertEqual(edAccount2.signingScheme, SigningScheme.singleKey)
        
        // Account with SingleKey Secp256k1 scheme
        let secpAccount = Account.generate(scheme: .secp256k1Ecdsa)
        XCTAssertTrue(secpAccount.publicKey is AnyPublicKey)
        XCTAssertEqual(secpAccount.signingScheme, SigningScheme.singleKey)
    }

    func testFromPrivateKeyAndAddress() async throws {
      try test("derives the correct account from a legacy ed25519 private key", { 
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let accountAddress = try AccountAddress.from(Ed25519.address)
        let newAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress, legacy: true))

        XCTAssertTrue(newAccount is Account.Ed25519Account)
        XCTAssertTrue(newAccount.publicKey is Ed25519PublicKey)
        XCTAssertTrue(newAccount.privateKey is Ed25519PrivateKey)
        XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
        XCTAssertEqual(newAccount.publicKey.toString(), Ed25519.publicKey)
        XCTAssertEqual(newAccount.accountAddress.toString(), Ed25519.address)
      })


      try test("derives the correct account from a single signer ed25519 private key", {
          let privateKey = try Ed25519PrivateKey(SingleSignerED25519.privateKey)
          let accountAddress = try AccountAddress.from(SingleSignerED25519.address)
          let newAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress, legacy: false))
          XCTAssertTrue(newAccount is Account.SingleKeyAccount)
          XCTAssertTrue(newAccount.publicKey is AnyPublicKey)
          XCTAssertTrue(newAccount.privateKey is Ed25519PrivateKey)
          XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
          XCTAssertEqual((newAccount.publicKey as! AnyPublicKey).publicKey.toString(), SingleSignerED25519.publicKey)
          XCTAssertEqual(newAccount.accountAddress.toString(), SingleSignerED25519.address)
      })

      try test("derives the correct account from a single signer secp256k1 private key", {
        let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
        let accountAddress = try AccountAddress.from(Secp256k1.address)
        let newAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress))
        XCTAssertTrue(newAccount is Account.SingleKeyAccount)
        XCTAssertTrue(newAccount.publicKey is AnyPublicKey)
        XCTAssertTrue(newAccount.privateKey is Secp256k1PrivateKey)
        XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
        XCTAssertEqual((newAccount.publicKey as! AnyPublicKey).publicKey.toString(), Secp256k1.publicKey)
        XCTAssertEqual(newAccount.accountAddress.toString(), Secp256k1.address)
      })

    }

    func testFromPrivateKey() async throws {
      try test("derives the correct account from a legacy ed25519 private key", {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let newAccount: Account.Ed25519Account = try Account.fromPrivateKey(privateKey)
        XCTAssertTrue(newAccount.publicKey is Ed25519PublicKey)
        XCTAssertTrue(newAccount.privateKey is Ed25519PrivateKey)
        XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
        XCTAssertEqual(newAccount.publicKey.toString(), try Ed25519PublicKey(Ed25519.publicKey).toString())
        XCTAssertEqual(newAccount.accountAddress.toString(), Ed25519.address)
      })

      try test("derives the correct account from a single signer ed25519 private key", {
        let privateKey = try Ed25519PrivateKey(SingleSignerED25519.privateKey)
        let newAccount: Account.SingleKeyAccount = try Account.fromPrivateKey(privateKey)
        XCTAssertTrue(newAccount.publicKey is AnyPublicKey)
        XCTAssertTrue(newAccount.privateKey is Ed25519PrivateKey)
        XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
        XCTAssertEqual((newAccount.publicKey as! AnyPublicKey).publicKey.toString(), try Ed25519PublicKey(SingleSignerED25519.publicKey).toString())
        XCTAssertEqual(newAccount.accountAddress.toString(), SingleSignerED25519.address)
      })

      try test("derives the correct account from a single signer secp256k1 private key", {
        let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
        let newAccount: Account.SingleKeyAccount = try Account.fromPrivateKey(privateKey)
        XCTAssertTrue(newAccount.publicKey is AnyPublicKey)
        XCTAssertTrue(newAccount.privateKey is Secp256k1PrivateKey)
        XCTAssertEqual(newAccount.privateKey.toString(), privateKey.toString())
        XCTAssertEqual((newAccount.publicKey as! AnyPublicKey).publicKey.toString(), try Secp256k1PublicKey(Secp256k1.publicKey).toString())
        XCTAssertEqual(newAccount.accountAddress.toString(), Secp256k1.address)
      })
    }

    func testFromDerivationPath() async throws {
      try test("should create a new account from bip44 path and mnemonics with legacy Ed25519", {
        let newAccount = try Account.fromDerivationPath(Wallet.path, mnemonic: Wallet.mnemonic)
        XCTAssertEqual(newAccount.accountAddress.toString(), Wallet.address)
      })

      try test("should create a new account from bip44 path and mnemonics with single signer Ed25519", {
        let newAccount = try Account.fromDerivationPath(Ed25519Wallet.path, mnemonic: Ed25519Wallet.mnemonic, scheme: .ed25519)
        XCTAssertEqual(newAccount.accountAddress.toString(), Ed25519Wallet.address)
      })

      try test("should create a new account from bip44 path and mnemonics with single signer secp256k1", {
        let newAccount = try Account.fromDerivationPath(Secp256k1Wallet.path, mnemonic: Secp256k1Wallet.mnemonic, scheme: .secp256k1Ecdsa)
        XCTAssertEqual(newAccount.accountAddress.toString(), Secp256k1Wallet.address)
      })

    }

    func testSignAndVerify() throws {
      try test("signs a message with single signer Secp256k1 scheme and verifies successfully", {
        let privateKey = try Secp256k1PrivateKey(Secp256k1.privateKey)
        let accountAddress = try AccountAddress.from(Secp256k1.address)
        let secpAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress))
        // verifies an encoded message
        let signature1 = try secpAccount.sign(message: Secp256k1.messageEncoded)
        XCTAssertEqual((signature1 as! AnySignature).signature.toString(), Secp256k1.signatureHex)
        XCTAssertTrue(try secpAccount.verifySignature(message: Secp256k1.messageEncoded, signature: signature1))
        // verifies a string message
        let signature2 = try secpAccount.sign(message: Secp256k1.stringMessage)
        XCTAssertEqual((signature2 as! AnySignature).signature.toString(), Secp256k1.signatureHex)
        XCTAssertTrue(try secpAccount.verifySignature(message: Secp256k1.stringMessage, signature: signature2))
      })

     
      try test("signs a message with single signer ed25519 scheme and verifies successfully", {
        let privateKey = try Ed25519PrivateKey(SingleSignerED25519.privateKey)
        let accountAddress = try AccountAddress.from(SingleSignerED25519.address)
        let edAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress, legacy: false))
        let signature = try edAccount.sign(message: SingleSignerED25519.messageEncoded)
        // TODO:, current Ed25519PrivageKey sign will ganrate a random signature every time. 
        // Need to find a way to generate a deterministic signature
        // XCTAssertEqual((signature as! AnySignature).signature.toString(), SingleSignerED25519.signatureHex)
        XCTAssertTrue(try edAccount.verifySignature(message: SingleSignerED25519.messageEncoded, signature: signature))
      })
      
      try test("signs a message with a legacy ed25519 scheme and verifies successfully", {
        let privateKey = try Ed25519PrivateKey(Ed25519.privateKey)
        let accountAddress = try AccountAddress.from(Ed25519.address)
        let legacyEdAccount = try Account.fromPrivateKey(.init(privateKey: privateKey, address: accountAddress, legacy: true))
        // verifies an encoded message
        let signature1 = try legacyEdAccount.sign(message: Ed25519.messageEncoded)
        // XCTAssertEqual((signature1 as! AnySignature).signature.toString(), Ed25519.signatureHex)
        XCTAssertTrue(try legacyEdAccount.verifySignature(message: Ed25519.messageEncoded, signature: signature1))
        // verifies a string message
        let signature2 = try legacyEdAccount.sign(message: Ed25519.stringMessage)
        // XCTAssertEqual((signature2 as! AnySignature).signature.toString(), Ed25519.signatureHex)
        XCTAssertTrue(try legacyEdAccount.verifySignature(message: Ed25519.stringMessage, signature: signature2))
      })

      try test("should return the authentication key for a public key", {
        let publicKey = try Ed25519PublicKey(Ed25519.publicKey)
        let authKey = try publicKey.authKey()
        XCTAssertEqual(try authKey.derivedAddress().toString(), Ed25519.address)
      })
    }
}   
