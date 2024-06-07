
import Foundation


public struct AccountApi: Sendable, AptosCapability, AccountAPIProtocol {
    public var config: AptosConfig
    
    public init(config: AptosConfig) {
        self.config = config
    }
}
