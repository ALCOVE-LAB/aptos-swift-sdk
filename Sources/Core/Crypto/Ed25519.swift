import Foundation
import BCS
import Types
import Crypto

/// L is the value that greater than or equal to will produce a non-canonical signature, and must be rejected
private let L = [
  0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58, 0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10,
];

/// Represents the public key of an Ed25519 key pair.
/// Since [AIP-55](https://github.com/aptos-foundation/AIPs/pull/263) Aptos supports
/// `Legacy` and `Unified` authentication keys.
///
/// Ed25519 scheme is represented in the SDK as `Legacy authentication key` and also
///  as `AnyPublicKey` that represents any `Unified authentication key`
public struct Ed25519PublicKey: AccountPublicKey {
	/// The length of an Ed25519 public key.
	public static let LENGTH = 32
	/// The public key as a Hex.
	public private(set) var key: Hex

	/// Initialize a public key from a HexInput.
	/// - Parameter hexInput: a HexInput
   	public init(_ hexInput: HexInput) throws {
        let hex = try Hex.fromHexInput(hexInput)

        if hex.toUInt8Array().count != Ed25519PublicKey.LENGTH {
            throw PublicKeyError.invalidLength
        }
        self.key = hex
    }

    /// Verify a signature for a message.
	/// - Parameters:
	///   - message: a signed message as a Hex string or Uint8Array
	///   - signature: the signature of the message
	/// - Returns: true if the signature is valid, false otherwise
    public func verifySignature(message: HexInput, signature: any Signature) throws -> Bool {
		guard let signature = signature as? Ed25519Signature else {
			return false
		}
		let messageToVerify = message.convertSigningMessage()
		let messageBytes = try Hex.fromHexInput(messageToVerify).toUInt8Array()
		let signatureBytes = signature.toUInt8Array()
		let publicKeyBytes = key.toUInt8Array()

		if !signature.isCanonicalSignature() {
			return false
		}
		return Curve25519.verify(signature: signatureBytes, message: messageBytes, publicKey: publicKeyBytes)
    }

	/// Get the authentication key for this public key.
	/// - Returns: 	AuthenticationKey
	public func authKey() throws -> AuthenticationKey {
		return try AuthenticationKey.fromSchemeAndBytes(scheme: .signing(.ed25519), input: toUInt8Array())
	}
	
	/// Get the public key in bytes (UInt8Array).
	/// - Returns: UInt8Array representation of the public key
	public func toUInt8Array() -> [UInt8] {
		return key.toUInt8Array()
	}
}

/// Represents the private key of an Ed25519 key pair.
public struct Ed25519PrivateKey: PrivateKey {
	/// The length of an Ed25519 private key.
	public static let LENGTH = 32

	public static let SLIP_0010_SE = "ed25519 seed"

	/// The private key as a Hex.
	public private(set) var signingKey: Hex

	/// Initialize a private key from a HexInput.
	/// Supports both legacy hex format and AIP-80 compliant format (ed25519-priv-<HEX>).
	/// - Parameter hexInput: a HexInput (hex string, AIP-80 string, or byte array)
	public init(_ hexInput: HexInput) throws {
		let privateKeyHex = try AIP80PrivateKey.parseHexInput(hexInput, type: .ed25519)
		if privateKeyHex.toUInt8Array().count != Ed25519PrivateKey.LENGTH {
			throw PrivateKeyError.invalidLength
		}
		self.signingKey = privateKeyHex
	}

	/// Generate a new random private key.
	/// - Returns: Ed25519PrivateKey
	public static func generate() -> Ed25519PrivateKey {
		let keyPar = Curve25519.Signing.PrivateKey()
		return try! Ed25519PrivateKey(keyPar.rawRepresentation)
	}

	public static func fromDerivationPath(path: String, mnemonic: String) throws -> Ed25519PrivateKey {
		if !path.isValidHardenedPath() {
			throw PrivateKeyError.invalidDerivationPath(path)
		}
		return try Ed25519PrivateKey.fromDerivationPathInner(path: path, seed: mnemonic.mnemonicToSeed())
	}

	private static func fromDerivationPathInner(
		path: String,
		seed: [UInt8],
		offset: UInt32 = HARDENED_OFFSET) throws -> Ed25519PrivateKey {
		let derivedKeys = deriveKey(Ed25519PrivateKey.SLIP_0010_SE, seed)
		let segments = path.splitPath().map({ UInt32($0, radix: 10) ?? 0})
		
		var parentKeys = derivedKeys
		
		for segment in segments {
			parentKeys = CKDPriv(keys: parentKeys, index: segment + offset)
		}
		return try Ed25519PrivateKey(parentKeys.key)
	}

	public func publicKey() throws -> any PublicKey {
		let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: toUInt8Array())
		return try Ed25519PublicKey(privateKey.publicKey.rawRepresentation)
	}

	/// Sign the given message with the private key.
	///
	/// - Parameters:
	///   - message: The message to sign.
	///
	/// - Returns: The signature for the message. the implementation of
	/// `Curve25519.Signing.PrivateKey` employs randomization to generate a
	/// different signature on every call, even for the same message and key, to
	/// guard against side-channel attacks.
	public func sign(message: HexInput) throws -> any Signature {
		let signingKey = try Curve25519.Signing.PrivateKey(rawRepresentation: signingKey.toUInt8Array())
		let messageToSign = message.convertSigningMessage()
		let messageBytes = try Hex.fromHexInput(messageToSign).toUInt8Array()
		let signatureBytes = try signingKey.signature(for: messageBytes)
		return try Ed25519Signature(signatureBytes)
	}

	public func toUInt8Array() -> [UInt8] {
		return signingKey.toUInt8Array()
	}

	public func toString() -> String {
		return signingKey.toString()
	}

	/// Format the private key as an AIP-80 compliant string.
	/// [Read about AIP-80](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-80.md)
	/// - Returns: An AIP-80 compliant string (e.g., "ed25519-priv-0x...")
	public func toAIP80String() throws -> String {
		return try AIP80PrivateKey.formatPrivateKey(signingKey, type: .ed25519)
	}
}


/// A signature of a message signed using an Ed25519 private key
public struct Ed25519Signature: Signature {
	/// The length of an Ed25519 signature.
	public static let LENGTH = 64
	/// The signature as a Hex.
  	private(set) var data: Hex

	/// Initialize a signature from a HexInput.
	/// - Parameter hexInput: a HexInput
	public init(_ hexInput: HexInput) throws {
		let hex = try Hex.fromHexInput(hexInput)
		if hex.toUInt8Array().count != Ed25519Signature.LENGTH {
			throw SignatureError.invalidLength
		}
		self.data = hex
	}

	/// Get the signature in bytes (UInt8Array).
	/// - Returns: UInt8Array representation of the signature
	public func toUInt8Array() -> [UInt8] {
		return data.toUInt8Array()
	}

  	/// Checks if an ED25519 signature is non-canonical.
	/// - Returns: true if the signature is canonical, false otherwise
	/// 
  	/// Comes from Aptos Core
	/// https://github.com/aptos-labs/aptos-core/blob/main/crates/aptos-crypto/src/ed25519/ed25519_sigs.rs#L47-L85
	public func isCanonicalSignature() -> Bool {
		let s = Array(self.toUInt8Array().suffix(from: 32))
		for i in stride(from: s.count - 1, through: 0, by: -1) {
			if s[i] < L[i] {
	            return true
			}
			if s[i] > L[i] {
				return false
			}
		}
		return false
	}
}