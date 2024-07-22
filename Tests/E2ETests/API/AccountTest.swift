//
//  AccountTest.swift
// 

import XCTest
import Clients
import Aptos
import Types
import Core
import BCS
import Transactions

struct Ed25519 {
    static let privateKey = "0xc5338cd251c22daa8c9c9cc94f498cc8a5c7e1d2e75287a5dda91096fe64efa5"
    static let publicKey = "0xde19e5d1880cac87d57484ce9ed2e84cf0f9599f12e7cc3a52e4e7657a763f2c"
    static let authKey = "0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"
    static let address = "0x978c213990c4833df71548df7ce49d54c759d6b6d932de22b24d56060b7af2aa"
    static let messageEncoded = "68656c6c6f20776f726c64"
    static let stringMessage = "hello world"
    static let signatureHex = "0x9e653d56a09247570bb174a389e85b9226abd5c403ea6c504b386626a145158cd4efd66fc5e071c0e19538a96a05ddbda24d3c51e1e6a9dacc6bb1ce775cce07"
}

final class AccountTest: XCTestCase {

    let FUND_AMOUNT = 100_000_000
    // the aptos env default is devnet & fullnode
    let aptos: Aptos = Aptos(aptosConfig: .init())
    
    func testAccountData() async throws {
        
        let data = try await aptos.account.getAccountInfo(address: "0x1")
        XCTAssertEqual(data.sequenceNumber, "0")
        XCTAssertEqual(data.authenticationKey, "0x0000000000000000000000000000000000000000000000000000000000000001")
    }

    func testAccountModules() async throws {
        let data = try await aptos.account.getAccountModules(address: "0x1")
        XCTAssertGreaterThan(data.count, 0)
    }

    func testAccountModule() async throws {
        let data = try await aptos.account.getAccountModule(address: "0x1", moduleName: "coin")
        XCTAssertNotNil(data.bytecode)
    }

    func testAccountResources() async throws {
        let data = try await aptos.account.getAccountResources(address: "0x1")
        XCTAssertGreaterThan(data.count, 0)
    }

    func testAccountResource() async throws {
        let data = try await aptos.account.getAccountResource(address: "0x1", resourceType: "0x1::account::Account")
        XCTAssertEqual(data.value["sequence_number"] as? String, "0")
        XCTAssertEqual(data.value["authentication_key"] as? String, "0x0000000000000000000000000000000000000000000000000000000000000001")
    }

    func testAccountResourceTypedWithSpecificModel() async throws {
        struct AccountRes: Codable & Sendable {
            let authentication_key: String
            let coin_register_events: Events
            let guid_creation_num: String
            let key_rotation_events: Events
            let sequence_number: String

            struct Events: Codable & Sendable {
                let counter: String
                let guid: Guid
                struct Guid: Codable & Sendable {
                    struct Id: Codable & Sendable {
                        let addr: String
                        let creation_num: String
                    }
                }
            }
        }
        let data: AccountRes = try await aptos.account.getAccountResource(
            address: "0x1",
            resourceType: "0x1::account::Account"
        )
        XCTAssertEqual(data.sequence_number, "0")
        XCTAssertEqual(data.authentication_key, "0x0000000000000000000000000000000000000000000000000000000000000001")
    }

    func testFetchAccountTransactions() async throws {
        let config = AptosConfig(network: .init(apiEnv: .local));
        let aptos = Aptos(aptosConfig: config)
        let senderAccount = Account.generate()
        let _ = try await aptos.faucet.fundAccount(
          accountAddress: senderAccount.accountAddress, 
          amount: FUND_AMOUNT)
        let bob = Account.generate()
        let rawTxn = try await aptos.transaction.build.simple(
          sender: senderAccount.accountAddress,
          data: InputEntryFunctionData(
            function: "0x1::aptos_account::transfer",
            functionArguments:[bob.accountAddress, U64(value: 10)])
        )
        let authenticator = try await aptos.transaction.sign.transaction(
            signer: senderAccount,
            transaction: rawTxn
        )
        let response = try await aptos.transaction.submit.simple(
            transaction: rawTxn,
            senderAuthenticator: authenticator
        )

        let txn: TransactionResponse = try await aptos.transaction.waitForTransaction(transactionHash: response.hash)
        let accountTransactions = try await aptos.account.getAccountTransactions(address: senderAccount.accountAddress)

        switch (accountTransactions[0], txn) {
            case let (.userTransaction(txn1), .userTransaction(txn2)):
                XCTAssertEqual(txn1, txn2)
            default:
                XCTAssert(false)
        }
    }
}
