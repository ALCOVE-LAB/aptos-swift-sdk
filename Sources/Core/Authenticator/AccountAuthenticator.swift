import Foundation
import BCS

public enum AccountAuthenticator: Serializable, Deserializable {
    case ed25519(Ed25519)
    case multiEd25519(MultiEd25519)
    case singleKey(SingleKey)
    case multiKey(MultiKey)

    public var signature: any Signature {
        switch self {
            case .ed25519(let ed25519):
                return ed25519.signature
            case .multiEd25519:
                fatalError()
            case .singleKey(let singleKey):
                return singleKey.signature
            case .multiKey:
                fatalError()
        }
    }

    var variant: Variant {
        switch self {
            case .ed25519:
                return .ed25519
            case .multiEd25519:
                return .multiEd25519
            case .singleKey:
                return .singleKey
            case .multiKey:
                return .multiKey
        }
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: variant.rawValue)
        switch self {
            case .ed25519(let ed25519):
                try ed25519.serialize(serializer: serializer)
            case .multiEd25519(let multiEd25519):
                try multiEd25519.serialize(serializer: serializer)
            case .singleKey(let singleKey):
                try singleKey.serialize(serializer: serializer)
            case .multiKey(let multiKey):
                try multiKey.serialize(serializer: serializer)
        }
    }

    public static func deserialize(deserializer: Deserializer) throws -> AccountAuthenticator {
        let index = try deserializer.deserializeVariantIndex()
        guard let variant = Variant(rawValue: index) else {
            throw AccountAuthenticatorError.invalidVariantIndex
        }
        switch variant {
            case .ed25519:
                return .ed25519(try Ed25519.deserialize(deserializer: deserializer))
            case .multiEd25519:
                return .multiEd25519(try MultiEd25519.deserialize(deserializer: deserializer))
            case .singleKey:
                return .singleKey(try SingleKey.deserialize(deserializer: deserializer))
            case .multiKey:
                return .multiKey(try MultiKey.deserialize(deserializer: deserializer))
        }
    
    }
}

extension AccountAuthenticator {
    enum Variant: UInt32 {
        case ed25519 = 0
        case multiEd25519 = 1
        case singleKey = 2
        case multiKey = 3
    }

    enum AccountAuthenticatorError: Error {
        case invalidVariantIndex
        case invalidSingleKeyVariantIndex
    }
}

extension AccountAuthenticator {

    public struct Ed25519: Serializable, Deserializable {
        public let publicKey: Ed25519PublicKey
        public let signature: any Signature

        public var rawSignature: Ed25519Signature {
            return signature as! Ed25519Signature
        }

        public init(publicKey: Ed25519PublicKey, signature: Ed25519Signature) {
            self.publicKey = publicKey
            self.signature = signature
        }

        public func serialize(serializer: Serializer) throws {
            try publicKey.serialize(serializer: serializer)
            try signature.serialize(serializer: serializer)
        }  
        public static func deserialize(deserializer: Deserializer) throws -> Ed25519 {
            let publicKey = try Ed25519PublicKey.deserialize(deserializer: deserializer)
            let signature = try Ed25519Signature.deserialize(deserializer: deserializer)
            return Ed25519(publicKey: publicKey, signature: signature)
        }
    }

    public struct MultiEd25519: Serializable, Deserializable {
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
    public struct SingleKey: Serializable, Deserializable {
        public let publicKey: AnyPublicKey
        public let signature: AnySignature

        public init(publicKey: AnyPublicKey, signature: AnySignature) {
            self.publicKey = publicKey
            self.signature = signature
        }

        public func serialize(serializer: Serializer) throws {
            try publicKey.serialize(serializer: serializer)
            try signature.serialize(serializer: serializer)
        }

        public static func deserialize(deserializer: Deserializer) throws -> SingleKey {
            let publicKey = try deserializer.deserialize(AnyPublicKey.self)
            let signature = try deserializer.deserialize(AnySignature.self)
            return SingleKey(publicKey: publicKey, signature: signature)
        }
    }

    public struct MultiKey: Serializable, Deserializable {
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