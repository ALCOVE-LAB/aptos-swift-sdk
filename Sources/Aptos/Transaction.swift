
import Foundation

public struct Transaction: Sendable, AptosCapability, TransactionAPIProtocol {
    public var config: AptosConfig
    
    init(config: AptosConfig) {
        self.config = config
    }
}
