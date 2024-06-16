import Foundation
import BCS

public enum AddressInvalidReason: String, Sendable {
    case incorrectNumberOfBytes = "incorrect_number_of_bytes"
    case invalidHexChars = "invalid_hex_chars"
    case tooShort = "too_short"
    case tooLong = "too_long"
    case leadingZeroXRequired = "leading_zero_x_required"
    case longFormRequiredUnlessSpecial = "long_form_required_unless_special"
    case invalidPaddingZeroes = "invalid_padding_zeroes"
    case invalidInputType = "invalid_input_type"
}

public protocol AccountAddressInput: Sendable {}

extension String: AccountAddressInput {}
extension Array: AccountAddressInput where Element == UInt8 {}
extension AccountAddress: AccountAddressInput {}
extension Data: AccountAddressInput {}


public struct AccountAddress: Sendable, Serializable, Deserializable {

    public static let LENGTH: Int = 32
    public static let LONG_STRING_LENGTH: Int = 64

    public static let ZERO: AccountAddress = try! AccountAddress.fromString("0x0")
    public static let ONE: AccountAddress = try! AccountAddress.fromString("0x1")
    public static let TWO: AccountAddress = try! AccountAddress.fromString("0x2")
    public static let THREE: AccountAddress = try! AccountAddress.fromString("0x3")
    public static let FOUR: AccountAddress = try! AccountAddress.fromString("0x4")

    public let data: [UInt8]

    public init(data: Data)  throws {
        try self.init(data: Array(data))
    }
     
    public init(data: [UInt8]) throws {
        if data.count != AccountAddress.LENGTH {
            throw ParsingError<AddressInvalidReason>(message: "AccountAddress data should be exactly 32 bytes long", reason: .incorrectNumberOfBytes)
        }
        self.data = data
    }

    public func isSpecial() -> Bool {
        return self.data.dropLast().allSatisfy { $0 == 0 } && self.data.last! < 0b10000
    }

    public func toUInt8Array() -> [UInt8] {
        return data
    }

    public func toStringWithoutPrefix() -> String {
        // to string without prefix, if it is a special address, return the last byte
        var hex = self.data.map { String(format: "%02hhx", $0) }.joined()
        if (isSpecial()) {
            hex = hex.suffix(1).description
        }
        return hex
    }

    public func toStringLongWithoutPrefix() -> String {
        return self.data.map { String(format: "%02hhx", $0) }.joined()
    }

    public func toString() -> String {
        return "0x" + self.toStringWithoutPrefix()
    }

    public func toStringLong() -> String {
        return "0x" + self.toStringLongWithoutPrefix()
    }

    public static func fromString(_ str: String) throws -> AccountAddress {

        var input = str

        if input.hasPrefix("0x") {
            input = String(input.dropFirst(2))
        }

        guard !input.isEmpty else {
            throw ParsingError<HexInvalidReason>(message: "Hex string is too short, must be at least 1 char long, excluding the optional leading 0x.", reason: .tooShort)
        }

        if (input.count > AccountAddress.LONG_STRING_LENGTH) {
            throw ParsingError<AddressInvalidReason>(message: "Hex string is too long, must be 1 to 64 chars long, excluding the leading 0x.", reason: .tooLong)
        }

        let addressBytes: [UInt8]
        input = String(repeating: "0", count: AccountAddress.LONG_STRING_LENGTH - input.count) + input
            
        if let data = Data(hex: input) {
            addressBytes = Array(data)
        } else {
            throw ParsingError<AddressInvalidReason>(message: "Hex characters are invalid", reason: .invalidHexChars)
        } 

        return try AccountAddress(data: addressBytes)
    }
   
    public static func fromStringStrict(_ input: String) throws -> AccountAddress {
        // Assert the string starts with 0x.
        guard input.hasPrefix("0x") else {
            throw ParsingError<AddressInvalidReason>(message: "Hex string must start with a leading 0x.", reason: .leadingZeroXRequired)
        }

        let address = try AccountAddress.fromString(input)

        // Check if the address is in LONG form. If it is not, this is only allowed for
        // special addresses, in which case we check it is in proper SHORT form.
        if input.count != AccountAddress.LONG_STRING_LENGTH + 2 {
            if !address.isSpecial() {
                throw ParsingError<AddressInvalidReason>(message: "The given hex string \(input) is not a special address, it must be represented as 0x + 64 chars.", reason: .longFormRequiredUnlessSpecial)
            } else if input.count != 3 {
                // 0x + one hex char is the only valid SHORT form for special addresses.
                throw ParsingError<AddressInvalidReason>(message: "The given hex string \(input) is a special address not in LONG form, it must be 0x0 to 0xf without padding zeroes.", reason: .invalidPaddingZeroes)
            }
        }

        return address
    }

    public static func from(_ input: AccountAddressInput) throws -> AccountAddress {
        switch input {
        case  let str as String:
            return try AccountAddress.fromString(str)
        case let data as Data:
            return try AccountAddress(data: data)
        case let array as [UInt8]:
            return try AccountAddress(data: array)
        case let address as AccountAddress:
            return address
        default: break
        }
        throw ParsingError<AddressInvalidReason>(message: "Invalid input type", reason: .invalidInputType)
    }

    public static func fromStrict(_ input: AccountAddressInput) throws -> AccountAddress {
        switch input {
        case let str as String:
            return try AccountAddress.fromStringStrict(str)
        default: return try AccountAddress.from(input)
        }
    }

    public static func isValid(_ str: String, strict: Bool = false) -> ParsingResult<AddressInvalidReason> {
        do {
            if (strict) {
                _ = try AccountAddress.fromStrict((str))
            } else {
                _ = try AccountAddress.from(str)
            }
            return ParsingResult(valid: true, invalidReason: nil, invalidReasonMessage: nil)
        } catch let error as ParsingError<AddressInvalidReason> {
            return ParsingResult(valid: false, invalidReason: error.reason, invalidReasonMessage: error.message)
        } catch {
            return ParsingResult(valid: false, invalidReason: nil, invalidReasonMessage: nil)
        }
    }

    public func equals(_ other: AccountAddress) -> Bool {
        if self.data.count != other.data.count {
            return false
        }
        return self.data.enumerated().allSatisfy { (index, value) in
            return value == other.data[index]
        }
    }
}

extension AccountAddress {
    public func serialize(serializer: Serializer) throws {
        try serializer.serializeFixedBytes(value: self.data)
    }

    public static func deserialize(deserializer: Deserializer) throws -> AccountAddress {
        let bytes = try deserializer.deserializeFixedBytes(AccountAddress.LENGTH)
        return try AccountAddress(data: bytes)
    }
}

extension AccountAddress: Equatable {
    public static func == (lhs: AccountAddress, rhs: AccountAddress) -> Bool {
        return lhs.equals(rhs)
    }
}