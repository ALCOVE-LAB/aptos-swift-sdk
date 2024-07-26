import XCTest
import Aptos
import Core

final class FaucetTest: XCTestCase {
    func testFaucet() async throws {
        let aptos = Aptos(aptosConfig: .localnet)
        let testAccount = Account.generate()
        try await aptos.faucet.fundAccount(
            accountAddress: testAccount.accountAddress,
            amount: 100_000_000)

        // Check the balance
        struct Coin: Codable & Sendable {
            let coin: CoinData

            struct CoinData: Codable & Sendable {
                let value: String
            }
        }
        let resource: Coin = try await aptos.account.getAccountResource(
            address: testAccount.accountAddress,
            resourceType: "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>")

        let amount = Int(resource.coin.value)
        XCTAssertEqual(amount, 100_000_000)
    }
}
