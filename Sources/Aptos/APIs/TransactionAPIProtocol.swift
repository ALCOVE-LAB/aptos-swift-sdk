
import Foundation
import Clients
import Types
import HTTPTypes


public struct WaitForTransactionError: Error {
    public var message: String
    public var lastTxn: TransactionResponse?
}
public struct FailedTransactionError: Error {
    public var message: String
    public var lastTxn: TransactionResponse?
}

public protocol TransactionAPIProtocol: Sendable {
    func getTransactions(page: Pagination?) async throws -> [TransactionResponse]
        
    func getTransactionByHash(_ transactionHash: HexInput) async throws -> TransactionResponse
    
    
    func getTransactionByVersion(_ ledgerVersion: String) async throws -> TransactionResponse
    
    func isPendingTransaction(transactionHash: HexInput) async throws -> Bool
    
    func getGasPriceEstimation() async throws -> GasEstimation
    
    func waitForTransaction(
        transactionHash: HexInput,
        options: WaitForTransactionOptions?
    ) async throws -> TransactionResponse
    
}

extension TransactionAPIProtocol where Self: AptosCapability {
    
    public func getTransactions(page: Pagination?) async throws -> [TransactionResponse] {
        var request: PagenationRequest & RequestOptions = TransactionApiOperation.GetTransactionsPage(page: page)
        return try await client.sendPaginateRequest(&request).body
    }
        
    public func getTransactionByHash(_ transactionHash: HexInput) async throws -> TransactionResponse {
        let hex = try Hex.fromHexInput(transactionHash).toString()
        return try await client.get(TransactionApiOperation.GetTransactions.byHash(hex)).body
    }
    
    
    public func getTransactionByVersion(_ ledgerVersion: String) async throws -> TransactionResponse {
        try await client.get(TransactionApiOperation.GetTransactions.byVersion(ledgerVersion)).body
    }
    
    public func isPendingTransaction(transactionHash: HexInput) async throws -> Bool {
        do {
            let resp = try await getTransactionByHash(transactionHash)
            if case .pendingTransaction(_) = resp {
                return true
            }
            return false
        } catch {
            if let error = error as? AptosApiError, error.status == 404 {
                return true
            }
            throw error
        }
    }
    
    public func getGasPriceEstimation() async throws -> GasEstimation {
        // TODO: support cache?
        try await client.get(TransactionApiOperation.GetTransactions.getGasPriceEstimation).body

    }
    
    
    public func waitForTransaction(
        transactionHash: HexInput,
        options: WaitForTransactionOptions? = nil
    ) async throws -> TransactionResponse {
        let timeoutSecs = options?.timeoutSecs ?? WaitForTransactionOptions.DEFAULT_TXN_TIMEOUT_SEC
        let checkSuccess = options?.checkSuccess ?? true
        
        var isPending = true
        var timeElapsed = 0
        var lastTxn: TransactionResponse?
        var lastError: AptosApiError?
        var backoffIntervalMs = 200
        let backoffMultiplier = 1.5

        func handleAPIError(_ e: Error) throws {
            let isAptosApiError = e is AptosApiError
            if !isAptosApiError {
                throw e
            }
            lastError = e as? AptosApiError
            let isRequestError = lastError?.status != 404 && lastError?.status ?? 0 >= 400 && lastError?.status ?? 0 < 500
            if isRequestError {
                throw e
            }
        }

        do {
            lastTxn = try await getTransactionByHash(transactionHash)
            if case .pendingTransaction = lastTxn {
                isPending = true
            } else {
                isPending = false
            }
        } catch {
            try handleAPIError(error)
        }

        if isPending {
            let startTime = Date().timeIntervalSince1970
            do {
                lastTxn = try await longWaitForTransaction(transactionHash: transactionHash)
                if case .pendingTransaction = lastTxn {
                    isPending = true
                } else {
                    isPending = false
                }
            } catch {
                try handleAPIError(error)
            }
            timeElapsed = Int(Date().timeIntervalSince1970 - startTime)
        }

        while isPending {
            if timeElapsed >= timeoutSecs {
                break
            }
            do {
                lastTxn = try await getTransactionByHash(transactionHash)
                if case .pendingTransaction = lastTxn {
                    isPending = true
                } else {
                    isPending = false
                }
                if !isPending {
                    break
                }
            } catch {
                try handleAPIError(error)
            }
            let backoffIntervalNs = UInt64(backoffIntervalMs) * 1_000_000
            try await Task.sleep(nanoseconds: backoffIntervalNs)
            timeElapsed += backoffIntervalMs / 1000
            backoffIntervalMs = Int(Double(backoffIntervalMs) * backoffMultiplier)
        }

        if lastTxn == nil {
            if let lastError = lastError {
                throw lastError
            } else {
                throw WaitForTransactionError(message: "Fetching transaction \(transactionHash) failed and timed out after \(timeoutSecs) seconds", lastTxn: lastTxn)
            }
        }

        if case .pendingTransaction = lastTxn {
            throw WaitForTransactionError(message: "Transaction \(transactionHash) timed out in pending state after \(timeoutSecs) seconds", lastTxn: lastTxn)
        }
        if !checkSuccess {
            return lastTxn!
        }
        if !(lastTxn?.success ?? false) {
            throw FailedTransactionError(message: "Transaction \(transactionHash) failed with an error: \(lastTxn?.vmStatus ?? "")", lastTxn: lastTxn)
        }
        
        return lastTxn!
    }
    
    private func longWaitForTransaction(transactionHash: HexInput) async throws -> TransactionResponse {
        // Implement this function
        let hash = try Hex.fromHexInput(transactionHash).toString()
        return try await client.get(TransactionApiOperation.GetTransactions.longWaitForTransaction(hash)).body
    }
}


struct TransactionApiOperation {
    struct GetTransactionsPage: PagenationRequest, RequestOptions {
        var page: Pagination?
        init(page: Pagination? = nil) {
            self.page = page
            
            var query: [String: Encodable] = [:]
            if let page = page {
                query["start"] = page.offset
                query["limit"] = page.limit
            }
            self.query = query
        }
        
        var query: [String : Encodable]?
        
        var path: String {
            return "/transactions"
        }
    }
    
    enum GetTransactions: RequestOptions {
        var query: [String : Encodable]? {
            return nil
        }
        
        case byHash(String)
        case byVersion(String)
        case longWaitForTransaction(String)
        case getGasPriceEstimation
        
        var path: String {
            switch self {
            case .byHash(let hash):
                return "/transactions/by_hash/\(hash)"
            case .byVersion(let ledgerVersion):
                return "/transactions/by_version/\(ledgerVersion)"
            case .longWaitForTransaction(let hash):
                return "/transactions/wait_by_hash/\(hash)"
            case .getGasPriceEstimation:
                return "/estimate_gas_price"
            }
        }
    }
}
