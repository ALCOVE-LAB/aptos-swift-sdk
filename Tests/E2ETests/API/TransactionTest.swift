

import XCTest
import Clients
import Aptos
import Types
import Core
import BCS

final class TransactionTest: XCTestCase {
    // the aptos env default is devnet & fullnode
    let aptos: Aptos = Aptos(aptosConfig: .init(network: .init(apiEnv: .local)))
    
    func testEstimateTransactionGas() async throws {
        let data = try await aptos.transaction.getGasPriceEstimation()
        XCTAssertGreaterThan(data.gasEstimate, 0)
        XCTAssertNotNil(data.deprioritizedGasEstimate)
        XCTAssertNotNil(data.prioritizedGasEstimate)
    }

    func testTransactionIsPending() async throws {
        let senderAccount = Account.generate()
        _ = try await aptos.faucet.fundAccount(accountAddress: senderAccount.accountAddress, amount: 100_000_000)
        let bob = Account.generate()
        let rawTxn = try await aptos.transaction.build.simple(
            sender: senderAccount.accountAddress,
            data: InputEntryFunctionData(
                function: "0x1::aptos_account::transfer",
                functionArguments: [bob.accountAddress, U64(value: 10)]
            )
        )
        let authenticator = try await aptos.transaction.sign.transaction(
            signer: senderAccount,
            transaction: rawTxn
        )
        let response = try await aptos.transaction.submit.simple(
            transaction: rawTxn,
            senderAuthenticator: authenticator
        )

        let isPending = try await aptos.transaction.isPendingTransaction(transactionHash: response.hash)
        XCTAssertTrue(isPending)
    }

    func testFetchTransactionQueries() async throws {
        let txn: TransactionResponse
        let senderAccount = Account.generate()
        _ = try await aptos.faucet.fundAccount(accountAddress: senderAccount.accountAddress, amount: 100_000_000)
        let bob = Account.generate()
        let rawTxn = try await aptos.transaction.build.simple(
            sender: senderAccount.accountAddress,
            data: InputEntryFunctionData(
                function: "0x1::aptos_account::transfer",
                functionArguments: [bob.accountAddress, U64(value: 10)]
            )
        )
        let authenticator = try await aptos.transaction.sign.transaction(
            signer: senderAccount,
            transaction: rawTxn
        )
        let response = try await aptos.transaction.submit.simple(
            transaction: rawTxn,
            senderAuthenticator: authenticator
        )
        txn = try await aptos.transaction.waitForTransaction(transactionHash: response.hash)

        // it queries for transactions on the chain
        let transactions = try await aptos.transaction.getTransactions()
        XCTAssertGreaterThan(transactions.count, 0)

        // it queries for transactions by version 
        if txn.version.isEmpty {
            XCTFail("Transaction is still pending, version is not available yet.")
        }
        let transaction = try await aptos.transaction.getTransactionByVersion(txn.version)
        XCTAssertEqual(transaction, txn)

        // it queries for transactions by hash
        let transactionByHash = try await aptos.transaction.getTransactionByHash(txn.hash)
        XCTAssertEqual(transactionByHash, txn)
    }

    func testLongPoll() async throws {
        let txn: TransactionResponse
        let senderAccount = Account.generate()
        _ = try await aptos.faucet.fundAccount(accountAddress: senderAccount.accountAddress, amount: 100_000_000)
        let bob = Account.generate()
        let rawTxn = try await aptos.transaction.build.simple(
            sender: senderAccount.accountAddress,
            data: InputEntryFunctionData(
                function: "0x1::aptos_account::transfer",
                functionArguments: [bob.accountAddress, 10]
            )
        )
        let authenticator = try await aptos.transaction.sign.transaction(
            signer: senderAccount,
            transaction: rawTxn
        )
        let response = try await aptos.transaction.submit.simple(
            transaction: rawTxn,
            senderAuthenticator: authenticator
        )
        txn = try await aptos.transaction.waitForTransaction(transactionHash: response.hash)

        // it queries for transactions by hash
        let transaction = try await aptos.transaction.getTransactionByHash(txn.hash)
        XCTAssertEqual(transaction, txn)
    }
}
