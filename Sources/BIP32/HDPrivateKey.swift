
import Foundation
import Crypto
import secp256k1

public struct HDPrivateKey {
    public let network: Network
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32

    public let raw: Data
    let chainCode: Data

    public init(privateKey: Data, chainCode: Data, network: Network) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = 0
        self.fingerprint = 0
        self.childIndex = 0
    }

    public init(seed: Data, network: Network) {
        let hmac = HMAC<SHA512>.authenticationCode(for: seed, using: SymmetricKey(data: "Bitcoin seed".data(using: .ascii)!))
        let privateKey = hmac.prefix(32)
        let chainCode = hmac.suffix(32)
        self.init(privateKey: Data(privateKey), chainCode: Data(chainCode), network: network)
    }

    init(privateKey: Data, chainCode: Data, network: Network, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.network = network
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func extendedPublicKey() throws -> HDPublicKey {
        return try HDPublicKey(raw: computePublicKeyData(), chainCode: chainCode, network: network, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
    }

    private func computePublicKeyData() throws -> Data {
        return try secp256k1.Signing.PrivateKey(dataRepresentation: raw, format: .compressed).publicKey.dataRepresentation
    }

    public func derived(at index: UInt32, hardened: Bool = false) throws -> HDPrivateKey {
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }
        
        let parentKey = HDPrivateKey(privateKey: raw, chainCode: chainCode, network: network, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
        
        var data = Data()
        
        if hardened {
            data.append(0x00)
            data.append(parentKey.raw)
        } else {
            data.append(try parentKey.extendedPublicKey().raw)
        }
        
        var indexBytes = index.bigEndian
        data.append(Data(bytes: &indexBytes, count: MemoryLayout.size(ofValue: indexBytes)))
        
        let hmac = HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: parentKey.chainCode))
        
        let privateKey = hmac.prefix(32)
        let chainCode = hmac.suffix(32)
    
        let newPrivateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: Data(privateKey), format: .compressed)
        
        let parentPublicKey = try secp256k1.Signing.PublicKey(dataRepresentation: parentKey.extendedPublicKey().raw, format: .compressed)
        let publicKeyHash = SHA256.hash(data: parentPublicKey.dataRepresentation)
        let newFingerprint = UInt32(bigEndian: Data(publicKeyHash.prefix(4)).withUnsafeBytes { $0.load(as: UInt32.self) })
        
        return HDPrivateKey(
            privateKey: newPrivateKey.dataRepresentation,
            chainCode: Data(chainCode),
            network: network,
            depth: parentKey.depth + 1,
            fingerprint: newFingerprint,
            childIndex: index
        )
    }
}


public enum DerivationError: Error {
    case derivationFailed
}
