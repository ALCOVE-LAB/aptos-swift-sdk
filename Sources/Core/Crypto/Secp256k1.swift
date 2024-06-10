import Foundation
import BCS
import Types
import secp256k1
import BIP32
import CryptoSwift
import Crypto

public struct Secp256k1PublicKey: PublicKey {
    
    public static let LENGTH = 65
    public private(set) var key: Hex

    public init(_ hexInput: HexInput) throws {
        let hex = try Hex.fromHexInput(hexInput)
        if hex.toUInt8Array().count != Secp256k1PublicKey.LENGTH {
            throw PublicKeyError.invalidLength
        }
        self.key = hex
    }

    public func verifySignature(message: HexInput, signature: any Signature) throws -> Bool {
        guard let signature = signature as? Secp256k1Signature else {
            return false
        }
        let messageBytes = try Hex.fromHexInput(message.convertSigningMessage()).toUInt8Array()
        let signatureBytes = signature.toUInt8Array()
        let messageSha3Bytes = CryptoSwift.Digest.sha3(messageBytes, variant: .sha256)
        let publicKeyBytes = key.toUInt8Array()
        return secp256k1.verify(signature: signatureBytes, data: messageSha3Bytes, publicKey: publicKeyBytes)
    }

    public func toUInt8Array() -> [UInt8] {
        return key.toUInt8Array()
    }

    static public func == (lhs: Secp256k1PublicKey, rhs: Secp256k1PublicKey) -> Bool {
        return lhs.key == rhs.key
    }
}

public struct Secp256k1PrivateKey: PrivateKey {
    
    public static let LENGTH = 32
    public private(set) var key: Hex

    public init(_ hexInput: HexInput) throws {
        let hex = try Hex.fromHexInput(hexInput)
        if hex.toUInt8Array().count != Secp256k1PrivateKey.LENGTH {
            throw PrivateKeyError.invalidLength
        }
        self.key = hex
    }

    public static func generate() throws -> Secp256k1PrivateKey {
        let privateKey = try secp256k1.Signing.PrivateKey(format: .uncompressed)
        return try Secp256k1PrivateKey(privateKey.dataRepresentation)
    }
    
    public static func fromDerivationPath(path: String, mnemonic: String) throws -> Secp256k1PrivateKey {
        guard path.isValidBIP44Path() else {
            throw PrivateKeyError.invalidBIP44Path(path)
        }
        return try fromDerivationPathInner(path: path, seed: mnemonic.mnemonicToSeed())
    }

    private static func fromDerivationPathInner(path: String, seed: [UInt8]) throws -> Secp256k1PrivateKey {
        let derivedKey = try HDKeychain(seed: Data(seed), network: .mainnet).derivedKey(path: path)
        return try Secp256k1PrivateKey(derivedKey.raw)
    }

    public func publicKey() throws -> any PublicKey {
        let privateKeyBytes = key.toUInt8Array()
        let privateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: privateKeyBytes)
        return try Secp256k1PublicKey(privateKey.publicKey.dataRepresentation)
    }

    public func sign(message: HexInput) throws -> any Signature {
        let messageToSign = message.convertSigningMessage()
        let messageBytes = try Hex.fromHexInput(messageToSign).toUInt8Array()
        let privaeKey = try secp256k1.Signing.PrivateKey(dataRepresentation: toUInt8Array())
        let sha3MessageBytes = CryptoSwift.Digest.sha3(messageBytes, variant: .sha256)
        let  signature = try privaeKey.signature(for: HashDigest(sha3MessageBytes))
        return try Secp256k1Signature(signature.compactRepresentation)
    }

    public func toUInt8Array() -> [UInt8] {
        return key.toUInt8Array()
    }

    public func toString() -> String {
        return key.toString()
    }
}


public struct Secp256k1Signature: Signature {

    public static let LENGTH = 64
    public private(set) var data: Hex

    public init(_ hexInput: Types.HexInput) throws {
        let data = try Hex.fromHexInput(hexInput)
        if data.toUInt8Array().count != Secp256k1Signature.LENGTH {
            throw SignatureError.invalidLength
        }
        self.data = data
    }
    
    public func toUInt8Array() -> [UInt8] {
        return data.toUInt8Array()
    }

    static public func == (lhs: Secp256k1Signature, rhs: Secp256k1Signature) -> Bool {
        return lhs.data == rhs.data
    }
}