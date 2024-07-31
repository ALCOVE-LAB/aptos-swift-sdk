import Foundation
import Types
import Core
import Clients
public protocol FaucetAPIProtocol {
    var faucetClient: any ClientInterface { get }
    var transaction: TransactionAPIProtocol { get }
    func fundAccount(accountAddress: AccountAddressInput, amount: Int, options: WaitForTransactionOptions?) async throws -> UserTransaction
}

extension FaucetAPIProtocol {
    @discardableResult
    public func fundAccount(
        accountAddress: AccountAddressInput,
        amount: Int, 
        options: WaitForTransactionOptions? = nil
    ) async throws -> UserTransaction {
        let accountAddress = try AccountAddress.from(accountAddress).toString()
        let operation = FaucetAPIOperation.fundAccount(accountAddress: accountAddress, amount: amount)
        let resp: AptosResponse<MoveStructValue> = try await faucetClient.post(operation)

        guard let txnHashes = resp.body.value["txn_hashes"] as? [String], !txnHashes.isEmpty else {
            preconditionFailure("No transaction hashes found in response")
        }

        let hash = txnHashes[0]

        let waitResp = try await transaction.waitForTransaction(
           transactionHash: hash,
           options: options
        )

        guard case let .userTransaction(trans) = waitResp else {
            throw WaitForTransactionError(message: "Unexpected transaction received for fund account: \(type(of: waitResp))", lastTxn: waitResp)
        }
        return trans
     }
}


private enum FaucetAPIOperation: PostRequestOptions {
    case fundAccount(accountAddress: String, amount: Int)
    var path: String { "/fund" }

    var body: RequestBody? {
        switch self {  
            case let .fundAccount(accountAddress, amount):
                return .json([
                    "address": accountAddress,
                    "amount": amount
                ])
        }
    }
}
