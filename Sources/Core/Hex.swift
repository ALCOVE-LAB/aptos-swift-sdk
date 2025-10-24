
import Foundation
import BCS

extension Serializable {
    public func bcsToHex() throws -> Hex {
        return Hex(data: try bcsToBytes())
    }
}

public struct ParsingError<T>: Error {
    public let message: String
    public let reason: T
}

public struct ParsingResult<T> {
    public let valid: Bool
    public let invalidReason: T?
    public let invalidReasonMessage: String?
}

public enum HexInvalidReason: String, Sendable {
    case tooShort = "too_short"
    case invalidLength = "invalid_length"
    case invalidHexChars = "invalid_hex_chars"
}

public protocol HexInput: Sendable, AccountAddressInput {}
extension String: HexInput {}
extension Data: HexInput {}
extension Array: HexInput where Element == UInt8 {}
// 0x1234
extension Int: HexInput {}
extension Hex: HexInput {} 

public struct Hex: Sendable {
    private let data: Data

    public init(data: Data) {
        self.data = data
    }
     
    public init(data: [UInt8]) {
        self.data = Data(data)
    }

    public func toUInt8Array() -> [UInt8] {
       return Array(data)
    }

    public func toStringWithoutPrefix() -> String {
        return self.data.map { String(format: "%02hhx", $0) }.joined()
    }

    public func toString() -> String {
        return "0x" + self.toStringWithoutPrefix()
    }

    public static func fromHexString(_ str: String) throws -> Hex {
        var input = str

        if input.hasPrefix("0x") {
            input = String(input.dropFirst(2))
        }

        guard !input.isEmpty else {
            throw ParsingError<HexInvalidReason>(message: "Hex string is too short, must be at least 1 char long, excluding the optional leading 0x.", reason: .tooShort)
        }

        guard input.count % 2 == 0 else {
            throw ParsingError<HexInvalidReason>(message: "Hex string must be an even number of hex characters.", reason: .invalidLength)
        }

        guard let data = Data(hex: input) else {
            throw ParsingError<HexInvalidReason>(message: "Hex string contains invalid hex characters.", reason: .invalidHexChars)
        }

        return Hex(data: data)
    }

    public static func fromHexInput(_ hexInput: HexInput) throws -> Hex {
        switch hexInput {
        case let hex as Hex:
            return hex
        case let str as String:
            return try Hex.fromHexString(str)
        case let data as Data:
            return Hex(data: data)
        case let array as [UInt8]:
            return Hex(data: array)
        case let num as Int:
            return try Hex.fromHexString(String(format: "0x%02X", num))
        default:
            throw ParsingError<HexInvalidReason>(message: "Invalid hex input type", reason: .invalidHexChars)
        }
    }

    public static func isValid(_ str: String) -> ParsingResult<HexInvalidReason> {
        do {
            _ = try Hex.fromHexString(str)
            return ParsingResult(valid: true, invalidReason: nil, invalidReasonMessage: nil)
        } catch let error as ParsingError<HexInvalidReason> {
            return ParsingResult(valid: false, invalidReason: error.reason, invalidReasonMessage: error.message)
        } catch {
            return ParsingResult(valid: false, invalidReason: nil, invalidReasonMessage: nil)
        }
    }

    public func equals(_ other: Hex) -> Bool {
        // compare data
        self.data == other.data
    }
}

extension Hex: Equatable {
    public static func == (lhs: Hex, rhs: Hex) -> Bool {
        lhs.equals(rhs)
    }
}

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i*2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
}
