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

    let aptos: Aptos = Aptos(aptosConfig: .init())
    
    func testAccountData() async throws {
        
        let data = try await aptos.account.getAccountInfo(address: "0x1")
        XCTAssertEqual(data.sequenceNumber, "0")
        XCTAssertEqual(data.authenticationKey, "0x0000000000000000000000000000000000000000000000000000000000000001")
    }

}
