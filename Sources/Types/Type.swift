import Foundation
import BCS

public struct ParsingError<T>: Error {
    public let message: String
    public let reason: T
}

public struct ParsingResult<T> {
    public let valid: Bool
    public let invalidReason: T?
    public let invalidReasonMessage: String?
}

extension Serializable {
  public func bcsToBytes() throws -> [UInt8] {
    let serializer = BcsSerializer()
    try serialize(serializer: serializer)
    return serializer.getBytes()
  }

  public func bcsToHex() throws -> Hex {
    return Hex(data: try bcsToBytes())
  }
}


// MARK: - Account

public struct AccountData: Codable, Hashable, Sendable {
    
    public var sequenceNumber: String
    
    public var authenticationKey: String
    
    public init(
        sequence_number: String,
        authentication_key: String
    ) {
        self.sequenceNumber = sequence_number
        self.authenticationKey = authentication_key
    }
    public enum CodingKeys: String, CodingKey {
        case sequenceNumber = "sequence_number"
        case authenticationKey = "authentication_key"
    }
}

// MARK: - Transaction
public enum ScriptTransactionArgumentVariants: Int {
  case U8 = 0
  case U64 = 1
  case U128 = 2
  case Address = 3
  case U8Vector = 4
  case Bool = 5
  case U16 = 6
  case U32 = 7
  case U256 = 8
}
