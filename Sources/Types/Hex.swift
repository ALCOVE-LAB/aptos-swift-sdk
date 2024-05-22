
import Foundation

public enum HexInvalidReason: String {
    case tooShort = "too_short"
    case invalidLength = "invalid_length"
    case invalidHexChars = "invalid_hex_chars"
}

public enum HexInput {
    case string(String)
    case data(Data)
    case array([UInt8])
    case num(Int) // 0xFF, 0x01
}

public struct Hex {
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
        case .string(let str):
            return try Hex.fromHexString(str)
        case .data(let data):
            return Hex(data: data)
        case .array(let array):
            return Hex(data: array)
        case .num(let num):
            return try Hex.fromHexString(String(format: "0x%02X", num))
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
