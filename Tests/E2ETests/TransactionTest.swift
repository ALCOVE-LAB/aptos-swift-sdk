

import XCTest
import Clients
import Aptos
import Types

final class TransactionTest: XCTestCase {
    // the aptos env default is devnet & fullnode
    let aptos: Aptos = Aptos(aptosConfig: .init())
    
    func testEstimateTransactionGas() async throws {
        let data = try await aptos.transaction.getGasPriceEstimation()
        XCTAssertGreaterThan(data.gasEstimate, 0)
        XCTAssertNotNil(data.deprioritizedGasEstimate)
        XCTAssertNotNil(data.prioritizedGasEstimate)
    }

    func testTransactionIsPending() async throws {

    }
}
