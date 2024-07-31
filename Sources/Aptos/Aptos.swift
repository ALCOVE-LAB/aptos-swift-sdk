import Foundation
import Utils
import OpenAPIRuntime
import HTTPTypes
import Types

public struct Aptos: Sendable {
    public let aptosConfig: AptosConfig
    public let account: Aptos.Account
    public let transaction: Aptos.Transaction
    public let faucet: Faucet
    public let general: Aptos.General
    
    public init(aptosConfig: AptosConfig) {
        self.aptosConfig = aptosConfig
        self.account = .init(config: aptosConfig)
        self.transaction = .init(config: aptosConfig)
        self.faucet = .init(config: aptosConfig, transaction: transaction)
        self.general = .init(config: aptosConfig)
    }
}