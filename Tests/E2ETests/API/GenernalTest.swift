
import XCTest
import Clients
import Aptos
import Types
import Core
import BCS
import Transactions
import Utils
import OpenAPIRuntime
import BigInt


final class GenernalTest: XCTestCase {

    func testFetchLedgerInfo() async throws {
        let aptos: Aptos = Aptos(aptosConfig: .localnet)
        let ledger = try await aptos.general.getLedgerInfo()
        XCTAssertEqual(ledger.chainId, 4)
    }

    func testFetchChainId() async throws {
        let aptos: Aptos = Aptos(aptosConfig: .localnet)
        let chainId = try await aptos.general.getChainId()
        XCTAssertEqual(chainId, 4)
    }

    func testFetchBlockDataByBlockHeight() async throws {
        let aptos: Aptos = Aptos(aptosConfig: .localnet)
        let blockHeight: UInt64 = 1
        let block = try await aptos.general.getBlockByHeight(blockHeight)
        XCTAssertEqual(block.blockHeight, "\(blockHeight)")
    }

    func testFetchBlockDataByBlockVersion() async throws {
        let aptos: Aptos = Aptos(aptosConfig: .localnet)
        let blockVersion: UInt64 = 1
        let block = try await aptos.general.getBlockByVersion(blockVersion)
        XCTAssertEqual(block.blockHeight, "\(blockVersion)")
    }

    func testFetchTableItemData() async throws {
        let aptos = Aptos(aptosConfig: .localnet)

        struct Supply: Codable & Sendable {
            let supply: SupplyData

            struct SupplyData: Codable & Sendable {
                let vec: [AggregatorData]

                struct AggregatorData: Codable & Sendable {
                    let aggregator: Aggregator

                    struct Aggregator: Codable & Sendable {
                        let vec: [Item]

                        struct Item: Codable & Sendable {
                            let handle: String
                            let key: String
                        }
                    }
                }
            }
        }
    
        let resource: Supply = try await aptos.account.getAccountResource(
            address: "0x1",
            resourceType: "0x1::coin::CoinInfo<0x1::aptos_coin::AptosCoin>"
        )

        let handle = resource.supply.vec[0].aggregator.vec[0].handle
        let key = resource.supply.vec[0].aggregator.vec[0].key

        let rawTableItem = try await aptos.general.getTableItem(
            handle: handle,
            data: .init(keyType: "address", valueType: "u128", key: key))

        var tableItem = String(data: rawTableItem, encoding: .utf8)!

        XCTAssert(tableItem.hasPrefix(""))
        XCTAssert(tableItem.hasSuffix(""))

        tableItem = tableItem.replacingOccurrences(of: "\"", with: "")
        let bigInt = BigInt(tableItem)
        XCTAssertGreaterThan(bigInt!, 0, "Supply should be greater than 0")
    }


    func testViewFunctions() async throws {

        // fetch view function data
        let aptos = Aptos(aptosConfig: .localnet)
        var payload = InputViewFunctionData(function: "0x1::chain_id::get")
        let chainIdValue = try await aptos.general.view(payload: payload)[0]
        XCTAssertEqual(chainIdValue as! Int, 4)

        // fetches view function with a type
        payload = InputViewFunctionData(function: "0x1::chain_id::get")
        let chainId: Int = try await aptos.general.view(payload: payload)[0]
        XCTAssertEqual(chainId, 4)

        // fetches view function with bool
        payload = InputViewFunctionData(
            function: "0x1::account::exists_at",
            functionArguments: [
                "0x1"
            ]
        )

        let exists: Bool = try await aptos.general.view(payload: payload)[0]
        XCTAssert(exists)

        payload = InputViewFunctionData(
            function: "0x1::account::exists_at",
            functionArguments: [
                "0x12345"
            ]
        )
        let exists2: Bool = try await aptos.general.view(payload: payload)[0]
        XCTAssertFalse(exists2)

        // fetches view function with address input and different output types
        payload = InputViewFunctionData(
            function: "0x1::account::get_sequence_number",
            functionArguments: [
                "0x1"
            ]
        )
        let sequenceNumber: String = try await aptos.general.view(payload: payload)[0]
        XCTAssertEqual(BigInt(sequenceNumber), 0)

        payload = InputViewFunctionData(
            function: "0x1::account::get_authentication_key",
            functionArguments: [
                "0x1"
            ]
        )

        let authKey: String = try await aptos.general.view(payload: payload)[0]
        XCTAssertEqual(authKey, "0x0000000000000000000000000000000000000000000000000000000000000001")

        // fetches view functions with generics
        payload = InputViewFunctionData(
            function: "0x1::coin::symbol",
            typeArguments: [
                "0x1::aptos_coin::AptosCoin"
            ]
        )
        
        let symbol: String = try await aptos.general.view(payload: payload)[0]
        XCTAssertEqual(symbol, "APT")

        payload = InputViewFunctionData(
            function: "0x1::coin::decimals",
            typeArguments: [
                "0x1::aptos_coin::AptosCoin"
            ]
        )
        let decimals: Int = try await aptos.general.view(payload: payload)[0]
        
        XCTAssertEqual(decimals, 8)

        payload = InputViewFunctionData(
            function: "0x1::coin::supply",
            typeArguments: [
                "0x1::aptos_coin::AptosCoin"
            ]
        )

        let supply = try await aptos.general.view(payload: payload).map { $0 as! [String: [String]] }[0]["vec"]![0]
        
        XCTAssertGreaterThan(BigInt(supply)!, 0)

        //view functions that fail in the VM fail here
        payload = InputViewFunctionData(
            function: "0x1::account::get_sequence_number",
            functionArguments: ["0x123456"]
        )

        do {
            let result = try await aptos.general.view(payload: payload)
            print(result[0])
            XCTFail("Expected error")
        } catch {
            XCTAssert(error is ClientError)
            XCTAssert(error.localizedDescription.contains("VMError"))
        }
    }
    
}   
