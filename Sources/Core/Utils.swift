import Foundation
import Types
import Crypto
import MnemonicSwift

typealias DerivedKeys = (key: [UInt8], chainCode: [UInt8])

func CKDPriv(keys: DerivedKeys, index: UInt32) -> DerivedKeys {
    var indexBigEndian = index.bigEndian
    let indexBytes = Data(bytes: &indexBigEndian, count: MemoryLayout<UInt32>.size)
    
    let zero: UInt8 = 0
    let zeroData = Data([zero])
    
    var data = Data()
    data.append(zeroData)
    data.append(Data(keys.key))
    data.append(indexBytes)

    return deriveKey(Data(keys.chainCode), data)
}

func deriveKey(_ hashSeed: Data, _ data: Data) -> DerivedKeys {
    // Generate HMAC-SHA512 digest
    var hmac = HMAC<SHA512>(key: SymmetricKey(data: hashSeed))
    hmac.update(data: data)    
    let digest = Data(hmac.finalize())
    let key = digest.prefix(32)
    let chainCode = digest.suffix(32)
    return (key: Array(key), chainCode: Array(chainCode))
}

func deriveKey(_ hashSeed: String, _ data: [UInt8]) -> DerivedKeys {
    guard let hashSeed = hashSeed.data(using: .utf8) else {
        fatalError("Failed to convert hashSeed to data")
    }
    return deriveKey(hashSeed, Data(data))
}

extension HexInput {
    func convertSigningMessage() -> HexInput  {
        if let str = self as? String {
           let isValid = Hex.isValid(str).valid
           if isValid {
               return str
           } else {
               return str.data(using: .utf8) ?? self
           }
        }
        return self
    }
}


extension Curve25519 {
    static func verify(signature: [UInt8], message: [UInt8], publicKey: [UInt8]) -> Bool {
        do {
            let edPublicKey = try Curve25519.Signing.PublicKey(rawRepresentation: publicKey)
            return edPublicKey.isValidSignature(signature, for: message)
        } catch {
            return false
        }
    }
}

// MARK: - hdKeys

let APTOS_HARDENED_REGEX = "^m/44'/637'/[0-9]+'/[0-9]+'/[0-9]+'?$"
let HARDENED_OFFSET: UInt32 = 0x80000000

extension String {
    func test(_ value: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", self)
        return predicate.evaluate(with: value)
    }
}

extension String {
    func isValidHardenedPath() -> Bool {
        return APTOS_HARDENED_REGEX.test(self)
    }
}

extension String {
    func mnemonicToSeed() throws -> [UInt8] {
        let normalizedMnemonic = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.lowercased() }
            .joined(separator: " ")
        return try Mnemonic.deterministicSeedBytes(from: normalizedMnemonic)
    }
}

extension String {
    func removeApostrophes() -> String {
        return self.replacingOccurrences(of: "'", with: "")
    }

    func splitPath() -> [String] {
        return self.split(separator: "/").dropFirst().map { (String($0).removeApostrophes()) }
    }
}
