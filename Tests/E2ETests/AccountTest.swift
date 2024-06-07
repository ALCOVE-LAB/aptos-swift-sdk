//
//  AccountTest.swift
//  
//
//  Created by wanglei on 2024/5/23.
//

import XCTest
import Clients
import Aptos
import Types

final class AccountTest: XCTestCase {
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
        let data: AccountRes = try await aptos.account.getAccountResource(address: "0x1", resourceType: "0x1::account::Account")
        XCTAssertEqual(data.sequence_number, "0")
        XCTAssertEqual(data.authentication_key, "0x0000000000000000000000000000000000000000000000000000000000000001")
    }

    // More: write features test with Account

}
