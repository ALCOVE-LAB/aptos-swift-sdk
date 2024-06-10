import Foundation
import Types
import BCS

/// Arguments for creating an opaque `Account` from any supported private key.
/// This is used when the private key type is not known at compilation time.
public struct CreateAccountFromPrivateKeyArgs {
    public let privateKey: any PrivateKey
    public let address: AccountAddressInput?
    public let legacy: Bool?
}

public protocol GenerateAccountProtocol {
    var scheme: SigningSchemeInput { get }
    var legacy: Bool? { get }
}

public protocol PrivateKeyFromDerivationPathProtocol {
    var path: String { get }
    var mnemonic: String { get }
}

/// Arguments for generating an opaque `Account`.
/// This is used when the input signature scheme is not known at compilation time.
public struct GenerateAccountArgs: GenerateAccountProtocol {
    public let scheme: SigningSchemeInput
    public let legacy: Bool? 

    static let ed25519Account = GenerateAccountArgs(scheme: .ed25519, legacy: true)
}

/// Arguments for deriving a private key from a mnemonic phrase and a BIP44 path.
public struct PrivateKeyFromDerivationPathArgs: GenerateAccountProtocol, PrivateKeyFromDerivationPathProtocol {
    public let scheme: SigningSchemeInput
    public let legacy: Bool?
    public let path: String
    public let mnemonic: String
}

public protocol AccountProtocol: Sendable {
    var privaeKey: any PrivateKey { get }
    var publicKey: any PublicKey { get }
    var accountAddress: AccountAddress { get }
    var signingScheme: SigningScheme { get }

    func signWithAuthenticator(message: HexInput) throws -> any AccountAuthenticatorProtoocl
}
extension AccountProtocol {
    public func verifySignature(message: HexInput, signature: any Signature) throws -> Bool {
        return try publicKey.verifySignature(message: message, signature: signature)
    }

    public func sign(message: HexInput) throws -> any Signature {
        return try signWithAuthenticator(message: message).signature
    }
}

enum Account {}

extension Account {
    static func generate(_ args: GenerateAccountProtocol) -> any AccountProtocol {
        if case .ed25519 = args.scheme, args.legacy == true {
            return Ed25519Account.generate()
        } 
        return SingleKeyAccount.generate(scheme: args.scheme)
    }
    static func generate(_ args: GenerateAccountArgs) -> any AccountProtocol {
        return generate(args as GenerateAccountProtocol)
    }
    static func generate() -> Ed25519Account {
        return generate(.ed25519Account) as! Ed25519Account
    }
    static func generate(scheme: SigningSchemeInput = .ed25519) -> SingleKeyAccount {
        return generate(.init(scheme: scheme, legacy: false)) as! SingleKeyAccount
    }
}

extension Account {
    public static func fromPrivateKey(_ args: CreateAccountFromPrivateKeyArgs) throws -> any AccountProtocol {
        if let privateKey = args.privateKey as? Ed25519PrivateKey, args.legacy == true {
            return try Ed25519Account(privateKey: privateKey, address: args.address)
        }
        return try SingleKeyAccount(privateKey: args.privateKey, address: args.address)
    }

    public static func fromPrivateKey(_ privateKey: Ed25519PrivateKey, address: AccountAddressInput? = nil) throws -> Ed25519Account {  
        try fromPrivateKey(.init(privateKey: privateKey, address: address, legacy: true)) as! Ed25519Account
    }

    public static func fromPrivateKey(_ privateKey: Ed25519PrivateKey, address: AccountAddressInput? = nil) throws -> SingleKeyAccount {
         try fromPrivateKey(.init(privateKey: privateKey, address: address, legacy: false)) as! SingleKeyAccount
    }

    public static func fromPrivateKey(_ privateKey: any PrivateKey, address: AccountAddressInput? = nil) throws -> SingleKeyAccount {
        try fromPrivateKey(.init(privateKey: privateKey, address: address, legacy: false)) as! SingleKeyAccount
    }
}

extension Account {
    public static func fromDerivationPath(_ args: GenerateAccountProtocol & PrivateKeyFromDerivationPathProtocol) throws -> any AccountProtocol {
        if case .ed25519 = args.scheme, args.legacy == true {
            return try Ed25519Account.fromDerivationPath(mnemonic: args.mnemonic, path: args.path)
        }
        return try SingleKeyAccount.fromDerivationPath(scheme: args.scheme, mnemonic: args.mnemonic, path: args.path)
    }

    public static func fromDerivationPath(_ args: PrivateKeyFromDerivationPathArgs) throws -> any AccountProtocol {
        return try fromDerivationPath(args as GenerateAccountProtocol & PrivateKeyFromDerivationPathProtocol)  
    }

    public static func fromDerivationPath(_ mnemonic: String, path: String) throws -> Ed25519Account {
        return try fromDerivationPath(.init(scheme: .ed25519, legacy: true, path: path, mnemonic: mnemonic)) as! Ed25519Account
    }

    public static func fromDerivationPath(scheme: SigningSchemeInput = .ed25519, _ mnemonic: String, path: String) throws -> SingleKeyAccount {
        return try fromDerivationPath(.init(scheme: scheme, legacy: false, path: path, mnemonic: mnemonic)) as! SingleKeyAccount
    }
}

extension Account {
    static func authKey(_ key: any AccountPublicKey) throws -> AuthenticationKey {
        try key.authKey()
    }
}

extension Account {

    enum AccountError: Error {
        case generateError
    }

    public struct Ed25519Account: AccountProtocol {
        public var privaeKey: any PrivateKey 
        public var publicKey: any PublicKey 
        public var accountAddress: AccountAddress 

        public var rawPublicKey: Ed25519PublicKey {
            return publicKey as! Ed25519PublicKey
        }

        public init(privateKey: Ed25519PrivateKey, address: AccountAddressInput? = nil) throws {
            self.privaeKey = privateKey
            guard let publicKey = try? privaeKey.publicKey() as? Ed25519PublicKey else {
                throw AccountError.generateError
            }
            self.publicKey = publicKey
            if case let .some(address) = address {
                self.accountAddress = try AccountAddress.from(address)
            } else {
                self.accountAddress = try publicKey.authKey().derivedAddress()
            }
        }

        public var signingScheme: SigningScheme  {
            return .ed25519
        }

        public func signWithAuthenticator(message: HexInput) throws -> any AccountAuthenticatorProtoocl {
            let signature = try privaeKey.sign(message: message) as! Ed25519Signature
            return  AccountAuthenticator.Ed25519(publicKey: rawPublicKey, signature: signature)
        }

        public static func generate() -> Ed25519Account {
            let privateKey = Ed25519PrivateKey.generate()
            return try! Ed25519Account(privateKey: privateKey, address: nil)
        }

        public static func fromDerivationPath(mnemonic: String, path: String) throws -> Ed25519Account {
            let privateKey = try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)
            return try Ed25519Account(privateKey: privateKey);
        }
    }

    public struct SingleKeyAccount: AccountProtocol {
        public var privaeKey: any PrivateKey 
        public var publicKey: any PublicKey 
        public var accountAddress: AccountAddress 
        public var signingScheme: SigningScheme {
            return .singleKey
        }

        public init(privateKey: any PrivateKey, address: AccountAddressInput? = nil) throws {
            self.privaeKey = privateKey
            self.publicKey = try privaeKey.publicKey() 
            if case let .some(address) = address {
                self.accountAddress = try AccountAddress.from(address)
            } else {
                self.accountAddress = try AuthenticationKey.fromSchemeAndBytes(
                    scheme: .signing(.singleKey),
                    input: self.publicKey.toUInt8Array()
                ).derivedAddress();
            }
        }

        public func signWithAuthenticator(message: HexInput) throws -> any AccountAuthenticatorProtoocl {
            let signature = try privaeKey.sign(message: message)
            return  AccountAuthenticator.SingleKey(publicKey: publicKey, signature: signature)
        }

        public static func generate(scheme: SigningSchemeInput) -> SingleKeyAccount {
            switch scheme {
            case .ed25519:
                let privateKey = Ed25519PrivateKey.generate()
                return try! SingleKeyAccount(privateKey: privateKey)
            case .secp256k1Ecdsa:
                let privateKey = Secp256k1PrivateKey.generate()
                return try! SingleKeyAccount(privateKey: privateKey)
            }
        }

        public static func fromDerivationPath(scheme: SigningSchemeInput, mnemonic: String, path: String) throws -> SingleKeyAccount {
            switch scheme {
                case .ed25519:
                    let privateKey = try Ed25519PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)
                    return try SingleKeyAccount(privateKey: privateKey)
                case .secp256k1Ecdsa: 
                    let privateKey = try Secp256k1PrivateKey.fromDerivationPath(path: path, mnemonic: mnemonic)
                    return try SingleKeyAccount(privateKey: privateKey)
            }
           
        }
    }
}