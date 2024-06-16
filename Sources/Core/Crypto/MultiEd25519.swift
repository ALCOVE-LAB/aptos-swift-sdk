import Foundation
import BCS

public struct MultiEd25519PublicKey: AccountPublicKey {
    public static let MAX_KEYS = 32
    public static let MIN_KEYS = 2
    public static let MIN_THRESHOLD = 1

    public let publicKeys: [Ed25519PublicKey]

    public let threshold: UInt8

    public init(_ hexInput: HexInput) throws {
        fatalError("Multied25519PublicKey does not support HexInput. use init(publicKeys: [Ed25519PublicKey], threshold: UInt8) instead")
    }

    public init(publicKeys: [Ed25519PublicKey], threshold: UInt8) {
        if publicKeys.count > MultiEd25519PublicKey.MAX_KEYS || publicKeys.count < MultiEd25519PublicKey.MIN_KEYS {
            fatalError("Must have between \(MultiEd25519PublicKey.MIN_KEYS) and \(MultiEd25519PublicKey.MAX_KEYS) public keys, inclusive")
        }

        if threshold < MultiEd25519PublicKey.MIN_THRESHOLD || threshold > publicKeys.count {
            fatalError("Threshold must be between \(MultiEd25519PublicKey.MIN_THRESHOLD) and \(publicKeys.count), inclusive")
        }

        self.publicKeys = publicKeys
        self.threshold = threshold
    }

    public func verifySignature(message: HexInput, signature: any Signature) throws -> Bool {
        guard let signature = signature as? MultiEd25519Signature else {
            return false
        }

        var indices: [Int] = []
        for i in 0..<4 {
            for j in 0..<8 {
                let bitIsSet = (signature.bitmap[i] & (1 << (7 - j))) != 0
                if bitIsSet {
                    let index = i * 8 + j
                    indices.append(index)
                }
            }
        }

        if indices.count != signature.signatures.count {
            fatalError("Bitmap and signatures length mismatch")
        }

        if indices.count < Int(threshold) {
            fatalError("Not enough signatures")
        }

        for i in 0..<indices.count {
            let publicKey = publicKeys[indices[i]]
            let verifyResult = try publicKey.verifySignature(message: message, signature: signature.signatures[i])
            if !verifyResult {
                return false
            }
        }
        return true
    }

    public func toUInt8Array() -> [UInt8] {
        var bytes: [UInt8] = []
        for k in publicKeys {
            bytes.append(contentsOf: k.toUInt8Array())
        }

        bytes.append(threshold)

        return bytes
    
    }

    public func authKey() throws -> AuthenticationKey {
        return try AuthenticationKey.fromSchemeAndBytes(scheme: .signing(.multiEd25519), input: toUInt8Array())
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }

    public static func deserialize(deserializer: Deserializer) throws -> MultiEd25519PublicKey {
        let bytes = try deserializer.deserializeBytes()
        let threshold = bytes[bytes.count - 1]

        var keys: [Ed25519PublicKey] = []

        for i in stride(from: 0, to: bytes.count - 1, by: Ed25519PublicKey.LENGTH) {
            let begin = i
            keys.append(try Ed25519PublicKey(Array(bytes[begin..<begin + Ed25519PublicKey.LENGTH])))
        }
        return MultiEd25519PublicKey(publicKeys: keys, threshold: threshold)
    }
}


public struct MultiEd25519Signature: Signature {
    public static let MAX_SIGNATURES_SUPPORTED = 32
    public static let BITMAP_LEN = 4

    public let signatures: [Ed25519Signature]
    public let bitmap: [UInt8]

    public init(_ hexInput: HexInput) throws {
        fatalError("Multied25519Signature does not support HexInput. ")
    }

    public init(signatures: [Ed25519Signature], bitmap: [UInt8]) {
        if signatures.count > MultiEd25519Signature.MAX_SIGNATURES_SUPPORTED {
            fatalError("The number of signatures cannot be greater than \(MultiEd25519Signature.MAX_SIGNATURES_SUPPORTED)")
        }
        self.signatures = signatures
        if bitmap.count != MultiEd25519Signature.BITMAP_LEN {
            fatalError("\"bitmap\" length should be \(MultiEd25519Signature.BITMAP_LEN)")
        }
        self.bitmap = bitmap
    }

    public func toUInt8Array() -> [UInt8] {
        var bytes: [UInt8] = []
        for k in signatures {
            bytes.append(contentsOf: k.toUInt8Array())
        }
        bytes.append(contentsOf: bitmap)
        return bytes
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeBytes(value: toUInt8Array())
    }

    public static func deserialize(deserializer: Deserializer) throws -> MultiEd25519Signature {
        let bytes = try deserializer.deserializeBytes()
        let bitmap = Array(bytes[bytes.count - 4..<bytes.count])

        var signatures: [Ed25519Signature] = []

        for i in stride(from: 0, to: bytes.count - 4, by: Ed25519Signature.LENGTH) {
            let begin = i
            signatures.append(try Ed25519Signature(Array(bytes[begin..<begin + Ed25519Signature.LENGTH])))
        }
        return MultiEd25519Signature(signatures: signatures, bitmap: bitmap)
    }

    public static func createBitmap(bits: [Int]) -> [UInt8] {
        let firstBitInByte: UInt8 = 128
        var bitmap: [UInt8] = [0, 0, 0, 0]

        var dupCheckSet: Set<Int> = []

        for bit in bits {
            if bit >= MultiEd25519Signature.MAX_SIGNATURES_SUPPORTED {
                fatalError("Cannot have a signature larger than \(MultiEd25519Signature.MAX_SIGNATURES_SUPPORTED - 1).")
            }

            if dupCheckSet.contains(bit) {
                fatalError("Duplicate bits detected.")
            }

            dupCheckSet.insert(bit)

            let byteOffset = bit / 8

            var byte = bitmap[byteOffset]

            byte |= firstBitInByte >> UInt8(bit % 8)

            bitmap[byteOffset] = byte
        }

        return bitmap
    }
}
