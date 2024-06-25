import Foundation
import Types
import BCS

public struct AnyPublicKey: AccountPublicKey {
    public let publicKey: any PublicKey
    public let variant: AnyPublicKeyVariant

    public init(_ hexInput: HexInput) throws {
        fatalError("AnySignature do not support init from HexInput")
    }

    public init(publicKey: any PublicKey) {
        self.publicKey = publicKey
        if publicKey is Ed25519PublicKey {
            self.variant = .ed25519
        } else if publicKey is Secp256k1PublicKey {
            self.variant = .secp256k1
        } else {
            fatalError("Unsupported public key type")
        }
    }

    public func verifySignature(message: HexInput, signature: any Signature) throws -> Bool {
      guard let signature = signature as? AnySignature else {
        return false
      }
      return try publicKey.verifySignature(message: message, signature: signature.signature)
    }

    public func toUInt8Array() -> [UInt8] {
        return try! self.bcsToBytes()
    }

    public func serialize(serializer: Serializer) throws {
      try serializer.serializeVariantIndex(value: variant.rawValue)
      try publicKey.serialize(serializer: serializer)
    } 

    public static func deserialize(deserializer: Deserializer) throws -> AnyPublicKey {
      let variantIndex = try deserializer.deserializeVariantIndex()
      guard let variant = AnyPublicKeyVariant(rawValue: variantIndex) else {
        fatalError("Unknown variant index for AnyPublicKey: \(variantIndex)")
      }
      switch variant {
        case .ed25519:
          return try AnyPublicKey(publicKey: deserializer.deserialize(Ed25519PublicKey.self))
        case .secp256k1:
          return try AnyPublicKey(publicKey: deserializer.deserialize(Secp256k1PublicKey.self))
      }
    }

  public func authKey() throws -> AuthenticationKey {
    return try AuthenticationKey.fromSchemeAndBytes(scheme: .signing(.singleKey), input: toUInt8Array())
  }

  public static func isPublicKey(_ publicKey: any AccountPublicKey) -> Bool {
    return publicKey is AnyPublicKey
  }

  public func isEd25519() -> Bool {
    return publicKey is Ed25519PublicKey
  }
  public func isSecp256k1() -> Bool {
    return publicKey is Secp256k1PublicKey
  }
}

public struct AnySignature: Signature {
    public let signature: any Signature
    public let variant: AnySignatureVariant

    public init(_ hexInput: HexInput) throws {
      fatalError("AnySignature do not support init from HexInput")
    }

    public init(signature: any Signature) {
        self.signature = signature
        if signature is Ed25519Signature {
            self.variant = .ed25519
        } else if signature is Secp256k1Signature {
            self.variant = .secp256k1
        } else {
            fatalError("Unsupported signature type")
        }
    }

    public func toUInt8Array() -> [UInt8] {
        return try! self.bcsToBytes()
    }

    public func serialize(serializer: Serializer) throws {
      try serializer.serializeVariantIndex(value: variant.rawValue)
      try signature.serialize(serializer: serializer)
    } 

    public static func deserialize(deserializer: Deserializer) throws -> AnySignature {
      let variantIndex = try deserializer.deserializeVariantIndex()
      guard let variant = AnySignatureVariant(rawValue: variantIndex) else {
        fatalError("Unknown variant index for AnySignature: \(variantIndex)")
      }
      switch variant {
        case .ed25519:
          return try AnySignature(signature: deserializer.deserialize(Ed25519Signature.self))
        case .secp256k1:
          return try AnySignature(signature: deserializer.deserialize(Secp256k1Signature.self))
      }
    }
}
