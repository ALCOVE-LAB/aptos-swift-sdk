import Foundation
import Types
import Core

public protocol FaucetAPIProtocol {
    func fundAccount(accountAddress: AccountAddressInput, amount: Int, options: WaitForTransactionOptions?) async throws -> UserTransaction
}
