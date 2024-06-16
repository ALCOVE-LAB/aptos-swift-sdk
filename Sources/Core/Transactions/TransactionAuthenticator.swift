import Foundation
import BCS

public enum TransactionAuthenticator: Serializable, Deserializable {
	case ed25519(Ed25519)
	case multiEd25519(MultiEd25519)
	case multiAgent(MultiAgent)
	case feePayer(FeePayer)
	case singleSender(SingleSender)

	
    var variant: Variant {
        switch self {
            case .ed25519:
                return .ed25519
            case .multiEd25519:
                return .multiEd25519
            case .multiAgent:
                return .multiAgent
            case .feePayer:
                return .feePayer
            case .singleSender:
                return .singleSender
        }
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: variant.rawValue)
        switch self {
            case .ed25519(let authenticator):
                try authenticator.serialize(serializer: serializer)
            case .multiEd25519(let authenticator):
                try authenticator.serialize(serializer: serializer)
            case .multiAgent(let authenticator):
                try authenticator.serialize(serializer: serializer)
            case .feePayer(let authenticator):
                try authenticator.serialize(serializer: serializer)
            case .singleSender(let authenticator):
                try authenticator.serialize(serializer: serializer)
        }
    }

    public static func deserialize(deserializer: Deserializer) throws -> TransactionAuthenticator {
        let index = try deserializer.deserializeVariantIndex()
        
        guard let variant = Variant(rawValue: index) else {
            throw TransactionAuthenticatorError.invalidVariantIndex
        }
        switch variant {
            case .ed25519:
                return .ed25519(try Ed25519.deserialize(deserializer: deserializer))
            case .multiEd25519:
                return .multiEd25519(try MultiEd25519.deserialize(deserializer: deserializer))
            case .multiAgent:
                return .multiAgent(try MultiAgent.deserialize(deserializer: deserializer))
            case .feePayer:
                return .feePayer(try FeePayer.deserialize(deserializer: deserializer))
            case .singleSender:
                return .singleSender(try SingleSender.deserialize(deserializer: deserializer))
        }
    }
 
}


public extension TransactionAuthenticator {
    enum Variant: UInt32 {
        case ed25519 = 0
        case multiEd25519 = 1
        case multiAgent = 2
        case feePayer = 3
        case singleSender = 4
    }

    enum TransactionAuthenticatorError: Error {
        case invalidVariantIndex
        case invalidSingleKeyVariantIndex
    }
}

extension TransactionAuthenticator {
    public struct Ed25519: Serializable, Deserializable {
        public let publicKey: Ed25519PublicKey
        public let signature: Ed25519Signature

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
}

extension TransactionAuthenticator {
    public struct MultiEd25519: Serializable, Deserializable {
        public let publicKey: MultiEd25519PublicKey
        public let signature: MultiEd25519Signature

        public init(publicKey: MultiEd25519PublicKey, signature: MultiEd25519Signature) {
            self.publicKey = publicKey
            self.signature = signature
        }

        public func serialize(serializer: Serializer) throws {
            try publicKey.serialize(serializer: serializer)
            try signature.serialize(serializer: serializer)
        }

        public static func deserialize(deserializer: Deserializer) throws -> MultiEd25519 {
            let publicKey = try MultiEd25519PublicKey.deserialize(deserializer: deserializer)
            let signature = try MultiEd25519Signature.deserialize(deserializer: deserializer)
            return MultiEd25519(publicKey: publicKey, signature: signature)
        }
    }
}

extension TransactionAuthenticator {
  public struct MultiAgent: Serializable, Deserializable {
    public let sender: AccountAuthenticator
    public let secondarySignerAddresses: [AccountAddress]
    public let secondarySigners: [AccountAuthenticator]

    public init(sender: AccountAuthenticator, secondarySignerAddresses: [AccountAddress], secondarySigners: [AccountAuthenticator]) {
      self.sender = sender
      self.secondarySignerAddresses = secondarySignerAddresses
      self.secondarySigners = secondarySigners
    }

    public func serialize(serializer: Serializer) throws {
      try sender.serialize(serializer: serializer)
      try serializer.serializeVector(values: secondarySignerAddresses)
      try serializer.serializeVector(values: secondarySigners)
    }

    public static func deserialize(deserializer: Deserializer) throws -> MultiAgent {
      let sender = try deserializer.deserialize(AccountAuthenticator.self)
      let secondarySignerAddresses = try deserializer.deserializeVector(AccountAddress.self)
      let secondarySigners = try deserializer.deserializeVector(AccountAuthenticator.self)
      return MultiAgent(sender: sender, secondarySignerAddresses: secondarySignerAddresses, secondarySigners: secondarySigners)
    }
  }
}

extension TransactionAuthenticator {
  public struct FeePayer: Serializable, Deserializable {
    public let sender: AccountAuthenticator
    public let secondarySignerAddresses: [AccountAddress]
    public let secondarySigners: [AccountAuthenticator]
    public let feePayer: (address: AccountAddress, authenticator: AccountAuthenticator)

    public init(sender: AccountAuthenticator, secondarySignerAddresses: [AccountAddress], secondarySigners: [AccountAuthenticator], feePayer: (address: AccountAddress, authenticator: AccountAuthenticator)) {
      self.sender = sender
      self.secondarySignerAddresses = secondarySignerAddresses
      self.secondarySigners = secondarySigners
      self.feePayer = feePayer
    }

    public func serialize(serializer: Serializer) throws {
      try sender.serialize(serializer: serializer)
      try serializer.serializeVector(values: secondarySignerAddresses)
      try serializer.serializeVector(values: secondarySigners)
      try feePayer.address.serialize(serializer: serializer)
      try feePayer.authenticator.serialize(serializer: serializer)
    }

    public static func deserialize(deserializer: Deserializer) throws -> FeePayer {
      let sender = try deserializer.deserialize(AccountAuthenticator.self)
      let secondarySignerAddresses = try deserializer.deserializeVector(AccountAddress.self)
      let secondarySigners = try deserializer.deserializeVector(AccountAuthenticator.self)
      let address = try deserializer.deserialize(AccountAddress.self)
      let authenticator = try deserializer.deserialize(AccountAuthenticator.self)
      let feePayer = (address: address, authenticator: authenticator)
      return FeePayer(sender: sender, secondarySignerAddresses: secondarySignerAddresses, secondarySigners: secondarySigners, feePayer: feePayer)
    }
  }
}


extension TransactionAuthenticator {
  public struct SingleSender: Serializable, Deserializable {
    public let sender: AccountAuthenticator

    public init(sender: AccountAuthenticator) {
      self.sender = sender
    }

    public func serialize(serializer: Serializer) throws {
      try sender.serialize(serializer: serializer)
    }

    public static func deserialize(deserializer: Deserializer) throws -> SingleSender {
      let sender = try deserializer.deserialize(AccountAuthenticator.self)
      return SingleSender(sender: sender)
    }
  }
}

/*

export abstract class TransactionAuthenticator extends Serializable {
  abstract serialize(serializer: Serializer): void;

  static deserialize(deserializer: Deserializer): TransactionAuthenticator {
    const index = deserializer.deserializeUleb128AsU32();
    switch (index) {
      case TransactionAuthenticatorVariant.Ed25519:
        return TransactionAuthenticatorEd25519.load(deserializer);
      case TransactionAuthenticatorVariant.MultiEd25519:
        return TransactionAuthenticatorMultiEd25519.load(deserializer);
      case TransactionAuthenticatorVariant.MultiAgent:
        return TransactionAuthenticatorMultiAgent.load(deserializer);
      case TransactionAuthenticatorVariant.FeePayer:
        return TransactionAuthenticatorFeePayer.load(deserializer);
      case TransactionAuthenticatorVariant.SingleSender:
        return TransactionAuthenticatorSingleSender.load(deserializer);
      default:
        throw new Error(`Unknown variant index for TransactionAuthenticator: ${index}`);
    }
  }
}


*/