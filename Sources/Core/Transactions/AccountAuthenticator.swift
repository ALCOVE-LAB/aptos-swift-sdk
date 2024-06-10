import Foundation
import BCS

public protocol AccountAuthenticatorProtoocl: Serializable, Deserializable {
    var signature: any Signature { get }
}

enum AccountAuthenticator {}

extension AccountAuthenticator {
    enum Variant: UInt32 {
        case ed25519 = 0
        case multiEd25519 = 1
        case singleKey = 2
        case multiKey = 3
    }

    enum AccountAuthenticatorError: Error {
        case invalidSingleKeyVariantIndex
    }
}

extension AccountAuthenticator {

    public struct Ed25519: AccountAuthenticatorProtoocl {
        public let publicKey: Ed25519PublicKey
        public let signature: any Signature

        public var rawSignature: Ed25519Signature {
            return signature as! Ed25519Signature
        }

        init(publicKey: Ed25519PublicKey, signature: Ed25519Signature) {
            self.publicKey = publicKey
            self.signature = signature
        }

        public func serialize(serializer: Serializer) throws {
            try serializer.serializeVariantIndex(value: Variant.ed25519.rawValue)
            try publicKey.serialize(serializer: serializer)
            try signature.serialize(serializer: serializer)
        }  
        static func deserialize(deserializer: Deserializer) throws -> Ed25519 {
            let publicKey = try Ed25519PublicKey.deserialize(deserializer: deserializer)
            let signature = try Ed25519Signature.deserialize(deserializer: deserializer)
            return Ed25519(publicKey: publicKey, signature: signature)
        }
    }

    public struct MultiEd25519: AccountAuthenticatorProtoocl {
        public var signature: any Signature {
            fatalError()
        }
        public func serialize(serializer: Serializer) throws {
            fatalError()
        }
        public static func deserialize(deserializer: Deserializer) throws -> MultiEd25519 {
            fatalError()
        }
    }
    public struct SingleKey: AccountAuthenticatorProtoocl {
        public enum Variant: UInt32 {
            case ed25519 = 0
            case secp256k1 = 1
        }
        public let variant: Variant
        public let publicKey: any PublicKey
        public let signature: any Signature

        init(publicKey: any PublicKey, signature: any Signature) {
            self.publicKey = publicKey
            self.signature = signature
            switch publicKey {
                case is Ed25519PublicKey:
                    self.variant = .ed25519
                case is Secp256k1PublicKey:
                    self.variant = .secp256k1
                default:
                    fatalError("Invalid public key type")
            }
        }

        public func serialize(serializer: Serializer) throws {
            try serializer.serializeVariantIndex(value: variant.rawValue)
            try publicKey.serialize(serializer: serializer)
            try signature.serialize(serializer: serializer)
        }

        public static func deserialize(deserializer: Deserializer) throws -> SingleKey {
            let variantIndex = try deserializer.deserializeVariantIndex()
            guard let variant = Variant(rawValue: variantIndex) else {
                throw AccountAuthenticatorError.invalidSingleKeyVariantIndex
            }
            switch variant {
                case .ed25519:
                    let publicKey = try Ed25519PublicKey.deserialize(deserializer: deserializer)
                    let signature = try Ed25519Signature.deserialize(deserializer: deserializer)
                    return SingleKey(publicKey: publicKey, signature: signature)
                case .secp256k1:
                    let publicKey = try Secp256k1PublicKey.deserialize(deserializer: deserializer)
                    let signature = try Secp256k1Signature.deserialize(deserializer: deserializer)
                    return SingleKey(publicKey: publicKey, signature: signature)
            }
        }
    }

    public struct MultiKey: AccountAuthenticatorProtoocl {
        public var signature: any Signature {
            fatalError()
        }
        public func serialize(serializer: Serializer) throws {
            fatalError()
        }
        public static func deserialize(deserializer: Deserializer) throws -> MultiKey {
            fatalError()
        }
    }

}