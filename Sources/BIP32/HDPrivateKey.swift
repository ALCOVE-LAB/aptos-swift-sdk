
import Foundation
import Crypto
import secp256k1
import CryptoKit
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
        guard let derivedKey = try _HDKey(privateKey: raw, publicKey: extendedPublicKey().raw, chainCode: chainCode, depth: depth, fingerprint: fingerprint, childIndex: childIndex).derived(at: index, hardened: hardened) else {
            throw DerivationError.derivationFailed
        }
        return HDPrivateKey(privateKey: derivedKey.privateKey!, chainCode: derivedKey.chainCode, network: network, depth: derivedKey.depth, fingerprint: derivedKey.fingerprint, childIndex: derivedKey.childIndex)
    }
}


public enum DerivationError: Error {
    case derivationFailed
}

struct _HDKey {
    let privateKey: Data?
    let publicKey: Data
    let chainCode: Data
    let depth: UInt8
    let fingerprint: UInt32
    let childIndex: UInt32

    private func hmacsha512(_ data: Data, key: Data) -> Data {
        let hmac = HMAC<SHA512>.authenticationCode(for: data, using: SymmetricKey(data: key))
        return Data(hmac)
    }

    private func sha256ripemd160(_ data: Data) -> Data {
        let sha256Hash = SHA256.hash(data: publicKey)

        var ripemd160Hash = RIPEMD160()
        ripemd160Hash.update(data: Data(sha256Hash))
        
        return ripemd160Hash.finalize()
    }

    func derived(at childIndex: UInt32, hardened: Bool) -> _HDKey? {
		var data = Data()
		if hardened {
			data.append(0)
			guard let privateKey = self.privateKey else {
				return nil
			}
			data.append(privateKey)
		} else {
			data.append(publicKey)
		}
		var childIndex = CFSwapInt32HostToBig(hardened ? (0x80000000 as UInt32) | childIndex : childIndex)
		data.append(Data(bytes: &childIndex, count: MemoryLayout<UInt32>.size))
		let digest = hmacsha512(data, key: self.chainCode)
		let derivedPrivateKey: [UInt8] = digest[0..<32].map { $0 }
		let derivedChainCode: [UInt8] = digest[32..<64].map { $0 }
		var result: Data
		if let privateKey = self.privateKey {
			guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
				return nil
			}
			defer { secp256k1_context_destroy(ctx) }
			var privateKeyBytes = privateKey.map { $0 }
			var derivedPrivateKeyBytes = derivedPrivateKey.map { $0 }
			if secp256k1_ec_seckey_tweak_add(ctx, &privateKeyBytes, &derivedPrivateKeyBytes) == 0 {
				return nil
			}
			result = Data(privateKeyBytes)
		} else {
			guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_VERIFY)) else {
				return nil
			}
			defer { secp256k1_context_destroy(ctx) }
			let publicKeyBytes: [UInt8] = publicKey.map { $0 }
			var secpPubkey = secp256k1_pubkey()
			if secp256k1_ec_pubkey_parse(ctx, &secpPubkey, publicKeyBytes, publicKeyBytes.count) == 0 {
				return nil
			}
			if secp256k1_ec_pubkey_tweak_add(ctx, &secpPubkey, derivedPrivateKey) == 0 {
				return nil
			}
			var compressedPublicKeyBytes = [UInt8](repeating: 0, count: 33)
			var compressedPublicKeyBytesLen = 33
			if secp256k1_ec_pubkey_serialize(ctx, &compressedPublicKeyBytes, &compressedPublicKeyBytesLen, &secpPubkey, UInt32(SECP256K1_EC_COMPRESSED)) == 0 {
				return nil
			}
			result = Data(compressedPublicKeyBytes)
		}
	    let fingerPrint: UInt32 = sha256ripemd160(publicKey).to(type: UInt32.self)
		return _HDKey(privateKey: result, publicKey: result, chainCode: Data(derivedChainCode), depth: self.depth + 1, fingerprint: fingerPrint, childIndex: childIndex)
    }
}