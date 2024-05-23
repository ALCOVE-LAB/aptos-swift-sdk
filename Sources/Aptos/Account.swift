
import Foundation

public struct Account: Sendable, AptosCapability, AccountAPIProtocol {
    public var config: AptosConfig
    
    public init(config: AptosConfig) {
        self.config = config
    }
}
