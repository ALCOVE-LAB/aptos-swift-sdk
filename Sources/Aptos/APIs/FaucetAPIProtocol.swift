import Foundation
import Clients
import Types
import HTTPTypes
import Core

public protocol FaucetAPIProtocol {
    func fundAccount(accountAddress: AccountAddressInput, amount: Int, options: WaitForTransactionOptions?) async throws -> UserTransaction
}
