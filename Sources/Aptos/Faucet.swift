import Foundation
import Clients
import OpenAPIRuntime
import HTTPTypes
import Types
import Core
import APIs

public struct Faucet: Sendable, FaucetAPIProtocol {
    let config: AptosConfig
    public let client: any ClientInterface
    let transaction: TransactionAPIProtocol

    init(config: AptosConfig, transaction: TransactionAPIProtocol) {
        self.config = config
        self.transaction = transaction

        let middleware = ClientConfigMiddleware(
            network: config.network,
            clientConfig: config.clientConfig,
            fullnodeConfig: config.fullnodeConfig,
            indexerConfig: config.indexerConfig,
            faucetConfig: config.faucetConfig
        )
        
        let serverURL = config.network.api(with: .faucet)
        
        self.client = Client(
            serverURL: serverURL,
            configuration: Configuration(),
            transport: config.transport,
            middlewares: [middleware, FaucetMiddleware()]
        )
    }

    public func fundAccount(accountAddress: AccountAddressInput, amount: Int, options: WaitForTransactionOptions? = nil) async throws -> UserTransaction {
        let accountAddress = try AccountAddress.from(accountAddress).toString()
        let operation = FaucetAPIOperation.fundAccount(accountAddress: accountAddress, amount: amount)
        let resp: AptosResponse<MoveStructValue> = try await client.post(operation)

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

struct FaucetMiddleware: ClientMiddleware {
    
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
         body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (
            HTTPTypes.HTTPRequest,
            OpenAPIRuntime.HTTPBody?, URL
        ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        var request = request
        
        request.headerFields.removeAll(where: { $0.name == .authorization })
        
        return try await next(request, body, baseURL)
    }
    
}

enum FaucetAPIOperation: PostRequestOptions {
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
