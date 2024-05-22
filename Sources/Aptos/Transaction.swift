
import Foundation

public struct Transaction: AptosCapability, TransactionAPIProtocol {
    public var config: AptosConfig
    
    init(config: AptosConfig) {
        self.config = config
    }
}
