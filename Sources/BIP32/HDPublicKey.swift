

import Foundation
import Crypto
import secp256k1

public struct HDPublicKey {
    public let network: Network
    public let depth: UInt8
    public let fingerprint: UInt32
    public let childIndex: UInt32

    public let raw: Data
    public let chainCode: Data

    init(raw: Data, chainCode: Data, network: Network = .testnet, depth: UInt8, fingerprint: UInt32, childIndex: UInt32) {
        self.network = network
        self.raw = raw
        self.chainCode = chainCode
        self.depth = depth
        self.fingerprint = fingerprint
        self.childIndex = childIndex
    }

    public func derived(at index: UInt32) throws -> HDPublicKey {
        if (0x80000000 & index) != 0 {
            fatalError("invalid child index")
        }
        
        let parentKey = HDPublicKey(raw: raw, chainCode: chainCode, network: network, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
        
        var data = Data()
        data.append(parentKey.raw)
        
        var indexBytes = index.bigEndian
        data.append(Data(bytes: &indexBytes, count: MemoryLayout.size(ofValue: indexBytes)))
        
        let hmac = HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: parentKey.chainCode))
        
        let privateKey = hmac.prefix(32)
        let chainCode = hmac.suffix(32)

        let newPrivateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: Data(privateKey), format: .compressed)
        
        let parentPublicKey = try secp256k1.Signing.PublicKey(dataRepresentation: parentKey.raw, format: .compressed)
        let publicKeyHash = SHA256.hash(data: parentPublicKey.dataRepresentation)
        let newFingerprint = UInt32(bigEndian: Data(publicKeyHash.prefix(4)).withUnsafeBytes { $0.load(as: UInt32.self) })
        
        return HDPublicKey(
            raw: newPrivateKey.publicKey.dataRepresentation,
            chainCode: Data(chainCode),
            network: self.network,
            depth: parentKey.depth + 1,
            fingerprint: newFingerprint,
            childIndex: index
        )
    }
}
