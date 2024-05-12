import Foundation
import Utils
import Clients
import OpenAPIRuntime
import Foundation

public class Aptos {
    public static func sayHello() {
        print("Hello from Aptos!")
    }
    
    public static func getAccount() async throws {
        print(Client.self)
//        Client(serverURL: try Servers.server1(), transport: <#ClientTransport#>).get_account_module(.init(path: .init(address: "dd", module_name: "abc")))
        _ = try await AccountClient().getAccount()
    }
}




extension Components.Schemas.Address {
    
}
