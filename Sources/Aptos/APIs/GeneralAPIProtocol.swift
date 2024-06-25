import Foundation
import Types
import Clients

public protocol GerneralAPIProtocol {
    var client: any ClientInterface { get }

    func getLedgerInfo() async throws -> LedgerInfo
}

extension GerneralAPIProtocol {
    public func getLedgerInfo() async throws -> LedgerInfo {
        return try await client.get(path: "").body
    }
}