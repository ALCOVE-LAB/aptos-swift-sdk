import Foundation

struct Ed25519 {
    static let privateKey = "0xc5338cd251c22daa8c9c9cc94f498cc8a5c7e1d2e75287a5dda91096fe64efa5"
    static let publicKey = "0xde19e5d1880cac87d57484ce9ed2e84cf0f9599f12e7cc3a52e4e7657a763f2c"
    static let authKey = "0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"
    static let address = "0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"
    static let messageEncoded = "68656c6c6f20776f726c64"
    static let stringMessage = "hello world"
    static let signatureHex = "0x9e653d56a09247570bb174a389e85b9226abd5c403ea6c504b386626a145158cd4efd66fc5e071c0e19538a96a05ddbda24d3c51e1e6a9dacc6bb1ce775cce07"
}

struct Wallet {
    static let address = "0x07968dab936c1bad187c60ce4082f307d030d780e91e694ae03aef16aba73f30"
    static let mnemonic = "shoot island position soft burden budget tooth cruel issue economy destroy above"
    static let path = "m/44'/637'/0'/0'/0'"
    static let privateKey = "0x5d996aa76b3212142792d9130796cd2e11e3c445a93118c08414df4f66bc60ec"
    static let publicKey = "0xea526ba1710343d953461ff68641f1b7df5f23b9042ffa2d2a798d3adb3f3d6c"
}

struct Secp256k1 {
    static let privateKey = "0xd107155adf816a0a94c6db3c9489c13ad8a1eda7ada2e558ba3bfa47c020347e"
    static let publicKey = "0x04acdd16651b839c24665b7e2033b55225f384554949fef46c397b5275f37f6ee95554d70fb5d9f93c5831ebf695c7206e7477ce708f03ae9bb2862dc6c9e033ea"
    static let address = "0x5792c985bc96f436270bd2a3c692210b09c7febb8889345ceefdbae4bacfe498"
    static let authKey = "0x5792c985bc96f436270bd2a3c692210b09c7febb8889345ceefdbae4bacfe498"
    static let messageEncoded = "68656c6c6f20776f726c64"
    static let stringMessage = "hello world"
    static let signatureHex = "0xd0d634e843b61339473b028105930ace022980708b2855954b977da09df84a770c0b68c29c8ca1b5409a5085b0ec263be80e433c83fcf6debb82f3447e71edca"
}