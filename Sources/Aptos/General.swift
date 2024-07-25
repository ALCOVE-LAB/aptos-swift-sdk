

import Foundation
import Clients
import OpenAPIRuntime
import APIs
import Transactions
import Utils
import BCS
import Types
extension Aptos {
    public struct General: Sendable, GerneralAPIProtocol {
        let aptosConfig: AptosConfig
        public let client: any ClientInterface

        private let builder: Builder
        
        init(config: AptosConfig) {
            self.aptosConfig = config

            let middleware = ClientConfigMiddleware(
                network: config.network,
                clientConfig: config.clientConfig,
                fullnodeConfig: config.fullnodeConfig,
                indexerConfig: config.indexerConfig,
                faucetConfig: config.faucetConfig
            )
            
            guard let serverURL = URL(string: config.network.fullNodeApi) else {
                fatalError("Failed to create an URL with the string '\(config.network.fullNodeApi)'.")
            }
            
            self.client = Client(
                serverURL: serverURL,
                configuration: Configuration(),
                transport: config.transport,
                middlewares: [middleware]
            )
            self.builder = Builder(aptosConfig: config, client: client)
        }
    }
}

extension Aptos.General {
   
    public func view<T>(payload: InputViewFunctionData, options: LedgerVersionArg? = nil) async throws -> Array<T> where T: MoveValue {
        let values: [MoveValue] = try await view(payload: payload, options: options)
        return values.map({  $0 as? T }).compactMap({ $0 })
    }

    public func view(payload: InputViewFunctionData, options: LedgerVersionArg? = nil) async throws -> Array<MoveValue> {
       let viewFunctionPayload = try await builder.generateViewFunctionPayload(payload.remoteABI(with : self.aptosConfig))
        
        let serializer = BcsSerializer()
        try viewFunctionPayload.serialize(serializer: serializer)
        let bytes = serializer.toUInt8Array()

        var query = [String: AnyNumber]()
        if let version = options?.ledgerVersion {
            query["ledger_version"] = version
        }

        let container: OpenAPIRuntime.OpenAPIArrayContainer = try await client.post(
            path: "/view", 
            query: query, 
            bobdy: .binary(.init(bytes)), 
            contentType: MimeType.bcsViewFunction).body
        return container.value.map(convertToMoveValue).compactMap({ $0 })
    }
}

private struct Builder: TransactionBuilder {
    let aptosConfig: AptosConfig
    let client: any ClientInterface
}