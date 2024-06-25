
import Foundation
import Types 
import BCS
import Crypto
import CryptoSwift

public enum AuthenticationKeyError: Error {
    case invalidLength
}

public struct AuthenticationKey: Serializable {
    public var data: Hex

    public static let LENGTH = 32

    public init(_ hex: Hex) throws {
        if hex.toUInt8Array().count != AuthenticationKey.LENGTH {
            throw AuthenticationKeyError.invalidLength
        }
        self.data = hex
    }

    public init(_ hexInput: HexInput) throws {
        let hex = try Hex.fromHexInput(hexInput)
        try self.init(hex)
    }

    public func toString() -> String {
        return data.toString()
    }

    public func toUInt8Array() -> [UInt8] {
        return data.toUInt8Array()
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeFixedBytes(value: data.toUInt8Array());
    }

    public static func deserialize(from deserializer: Deserializer) throws -> AuthenticationKey {
        let bytes = try deserializer.deserializeFixedBytes(AuthenticationKey.LENGTH)
        return try AuthenticationKey(bytes)
    }

    public static func fromSchemeAndBytes(scheme: AuthenticationKeyScheme, input: HexInput) throws -> AuthenticationKey {
        let inputBytes = try Hex.fromHexInput(input).toUInt8Array()
        let hashInput = inputBytes + [UInt8(scheme.rawValue)]
        let hashDigest = CryptoSwift.Digest.sha3(hashInput, variant: SHA3.Variant.sha256)
        return try AuthenticationKey(hashDigest.makeIterator().map { $0 })
    }

    public static func fromPublicKey(_ publicKey: any AccountPublicKey) throws -> AuthenticationKey {
        return try publicKey.authKey()
    }

    public func derivedAddress() throws -> AccountAddress {
        return try AccountAddress(data: data.toUInt8Array())
    }
}
