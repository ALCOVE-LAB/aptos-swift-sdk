
import Foundation

struct Account: AptosCapability, AccountAPIProtocol {
    var config: AptosConfig
    
    init(config: AptosConfig) {
        self.config = config
    }
}
