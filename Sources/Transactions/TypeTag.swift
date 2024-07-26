import Foundation
import BCS
import Types
import Core

public enum TypeTagError: Error {
    case invalidVariantIndex
}

public indirect enum TypeTag: Serializable, Deserializable, Equatable, Sendable {
    case Bool
    case U8
    case U16
    case U32
    case U64
    case U128
    case U256
    case Address
    case Signer
    case Vector(TypeTag)
    case Struct(StructTag)
    case Reference(TypeTag)
    case Generic(UInt32)

    var variant: TypeTagVariants {
        switch self {
            case .Bool:
                return .Bool
            case .U8:
                return .U8
            case .U16:
                return .U16
            case .U32:
                return .U32
            case .U64:
                return .U64
            case .U128:
                return .U128
            case .U256:
                return .U256
            case .Address:
                return .Address
            case .Signer:
                return .Signer
            case .Vector:
                return .Vector
            case .Struct:
                return .Struct
            case .Reference:
                return .Reference
            case .Generic:
                return .Generic
        }
    }

    var variantIndex: UInt32 {
        return variant.rawValue
    }

    public func serialize(serializer: Serializer) throws {
        try serializer.serializeVariantIndex(value: variantIndex)
        switch self {
            case .Vector(let value):
                try value.serialize(serializer: serializer)
            case .Struct(let value):
                try value.serialize(serializer: serializer)
            case .Reference(let value):
                try value.serialize(serializer: serializer)
            case .Generic(let value):
                try serializer.serializeU32(value: value)
            default: break
        }
    }

    public func toString() -> String   {
        switch self {
            case .Bool:
                return "bool"
            case .U8:
                return "u8"
            case .U16:
                return "u16"
            case .U32:
                return "u32"
            case .U64:
                return "u64"
            case .U128:
                return "u128"
            case .U256:
                return "u256"
            case .Address:
                return "address"
            case .Signer:
                return "signer"
            case .Vector(let value):
                return "vector<\(value.toString())>"
            case .Struct(let value):
                return "\(value.address.toString())::\(value.moduleName.identifier)::\(value.name.identifier)"
            case .Reference(let value):
                return "&\(value.toString())"
            case .Generic(let value):
                return "T\(value)"
        }
    }

    public static func deserialize(deserializer: Deserializer) throws -> TypeTag {
      let index = try deserializer.deserializeVariantIndex()
      guard let variant = TypeTagVariants(rawValue: index) else {
          throw TypeTagError.invalidVariantIndex
      }
      switch variant {
          case .Bool:
              return .Bool
          case .U8:
              return .U8
          case .U16:
              return .U16
          case .U32:
              return .U32
          case .U64:
              return .U64
          case .U128:
              return .U128
          case .U256:
              return .U256
          case .Address:
              return .Address
          case .Signer:
              return .Signer
          case .Vector:
              let value = try TypeTag.deserialize(deserializer: deserializer)
              return .Vector(value)
          case .Struct:
              let value = try StructTag.deserialize(deserializer: deserializer)
              return .Struct(value)
          case .Reference:
              let value = try TypeTag.deserialize(deserializer: deserializer)
              return .Reference(value)
          case .Generic:
              let value = try deserializer.deserializeU32()
              return .Generic(value)
      }
    }

    public static func ==(lhs: TypeTag, rhs: TypeTag) -> Bool {
        switch (lhs, rhs) {
            case (.Bool, .Bool):
                return true
            case (.U8, .U8):
                return true
            case (.U16, .U16):
                return true
            case (.U32, .U32):
                return true
            case (.U64, .U64):
                return true
            case (.U128, .U128):
                return true
            case (.U256, .U256):
                return true
            case (.Address, .Address):
                return true
            case (.Signer, .Signer):
                return true
            case (.Vector(let lhsValue), .Vector(let rhsValue)):
                return lhsValue == rhsValue
            case (.Struct(let lhsValue), .Struct(let rhsValue)):
                return lhsValue == rhsValue
            case (.Reference(let lhsValue), .Reference(let rhsValue)):
                return lhsValue == rhsValue
            case (.Generic(let lhsValue), .Generic(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
        }
    }
}

extension TypeTag {

    public var isStruct: Bool {
        switch self {
            case .Struct:
                return true
            default:
                return false
        }
    }

    func isTypeTag(_ address: AccountAddress, _ moduleName: String, _ structName: String) -> Bool {
        switch self {
            case .Struct(let value):
                return value.address.equals(address) &&
                    value.moduleName.identifier == moduleName &&
                    value.name.identifier == structName
                default: return false
        }
    }

    public func isString() -> Bool {
        return isTypeTag(AccountAddress.ONE, "string", "String");
    }

    public func isOption() -> Bool {
        return isTypeTag(AccountAddress.ONE, "option", "Option");
    }

    public func isObject() -> Bool {
        return isTypeTag(AccountAddress.ONE, "object", "Object");
    }

    public struct StructTag: Serializable, Deserializable, Equatable, Sendable {
        public let address: AccountAddress
        public let moduleName: Identifier
        public let name: Identifier
        public let typeArgs: [TypeTag]

        public init(address: AccountAddress, moduleName: Identifier, name: Identifier, typeArgs: [TypeTag]) {
            self.address = address
            self.moduleName = moduleName
            self.name = name
            self.typeArgs = typeArgs
        }

        public func serialize(serializer: Serializer) throws {
            try serializer.serialize(value: address)
            try serializer.serialize(value: moduleName)
            try serializer.serialize(value: name)
            try serializer.serializeVector(values: typeArgs)
        }

        public static func deserialize(deserializer: Deserializer) throws -> StructTag {
            let address = try deserializer.deserialize(AccountAddress.self)
            let moduleName = try deserializer.deserialize(Identifier.self)
            let name = try deserializer.deserialize(Identifier.self)
            let typeArgs = try deserializer.deserializeVector(TypeTag.self)
            return .init(address: address, moduleName: moduleName, name: name, typeArgs: typeArgs)
        }

        public static func ==(lhs: StructTag, rhs: StructTag) -> Bool {
            return lhs.address == rhs.address &&
                lhs.moduleName == rhs.moduleName &&
                lhs.name == rhs.name &&
                lhs.typeArgs == rhs.typeArgs
        }
    }
}

extension TypeTag {
    public struct ParseError: LocalizedError {
        public enum ErrorKind: String {
            case invalidTypeTag = "unknown type"
            case unexpectedGenericType = "unexpected generic type"
            case unexpectedTypeArgumentClose = "unexpected '>'"
            case unexpectedWhitespaceCharacter = "unexpected whitespace character"
            case unexpectedComma = "unexpected ','"
            case typeArgumentCountMismatch = "type argument count doesn't match expected amount"
            case missingTypeArgumentClose = "no matching '>' for '<'"
            case unexpectedPrimitiveTypeArguments = "primitive types not expected to have type arguments"
            case unexpectedVectorTypeArgumentCount = "vector type expected to have exactly one type argument"
            case unexpectedStructFormat = "unexpected struct format, must be of the form 0xaddress::module_name::struct_name"
            case invalidModuleNameCharacter = "module name must only contain alphanumeric or '_' characters"
            case invalidStructNameCharacter = "struct name must only contain alphanumeric or '_' characters"

        }
        public let typeTagStr: String
        public let kind: ErrorKind

        public var errorDescription: String {
            return localizedDescription
        }
        public var localizedDescription: String {
            return "Failed to parse typeTag '\(typeTagStr)', \(kind.rawValue)"
        }
    }
}

func isGeneric(_ str: String) -> Bool {
    return str.range(of: "^T[0-9]+$", options: .regularExpression) != nil
}


func isValidIdentifier(_ str: String) -> Bool {
    return str.range(of: "^[_a-zA-Z0-9]+$", options: .regularExpression) != nil
}

func consumeWhitespace(typeStr: String, cur: Int) -> Int {
    var i = cur
    while i < typeStr.count {
        let innerChar = typeStr[typeStr.index(typeStr.startIndex, offsetBy: i)]
        if !innerChar.isWhitespace {
            break
        }
        i += 1
    }
    return i
}

extension TypeTag {

    private struct State {
        let expectedTypes: Int
        let str: String
        let types: [TypeTag]
    }

    public static func parseTypeTag(_ typeStr: String, allowGenerics: Bool = false) throws -> TypeTag {
        var saved: [State] = []   
        var innerTypes: [TypeTag] = []
        var curTypes: [TypeTag] = []
        var cur = 0
        var currentStr = ""
        var expectedTypes = 1

        while cur < typeStr.count {
            let char = typeStr[typeStr.index(typeStr.startIndex, offsetBy: cur)]
            if char == "<" {
                saved.append(State(expectedTypes: expectedTypes, str: currentStr, types: curTypes))
                currentStr = ""
                curTypes = []
                expectedTypes = 1
            } else if char == ">" {
                if !currentStr.isEmpty {
                    let newType = try _parseTypeTag(str: currentStr, types: innerTypes, allowGenerics: allowGenerics)
                    curTypes.append(newType)
                }
                let savedPop = saved.popLast()
                if savedPop == nil {
                    throw ParseError(typeTagStr: typeStr, kind: .unexpectedTypeArgumentClose)
                }
                if expectedTypes != curTypes.count {
                    throw ParseError(typeTagStr: typeStr, kind: .typeArgumentCountMismatch)
                }
                if let savedPop = savedPop {
                    innerTypes = curTypes
                    curTypes = savedPop.types
                    currentStr = savedPop.str
                    expectedTypes = savedPop.expectedTypes
                }
            } else if char == "," {
                if !currentStr.isEmpty {
                    let newType = try _parseTypeTag(str: currentStr, types: innerTypes, allowGenerics: allowGenerics)
                    innerTypes = []
                    curTypes.append(newType)
                    currentStr = ""
                    expectedTypes += 1
                }
            } else if char.isWhitespace {
                var parsedTypeTag = false
                if !currentStr.isEmpty {
                    let newType = try _parseTypeTag(str: currentStr, types: innerTypes, allowGenerics: allowGenerics)
                    innerTypes = []
                    curTypes.append(newType)
                    currentStr = ""
                    parsedTypeTag = true
                }
                cur = consumeWhitespace(typeStr: typeStr, cur: cur)
                let nextChar = typeStr[typeStr.index(typeStr.startIndex, offsetBy: cur)]
                if cur < typeStr.count && parsedTypeTag && nextChar != "," && nextChar != ">" {
                    throw ParseError(typeTagStr: typeStr, kind: .unexpectedWhitespaceCharacter)
                }
                continue
            } else {
                currentStr.append(char)
            }
            cur += 1
        }

        if !saved.isEmpty {
            throw ParseError(typeTagStr: typeStr, kind: .missingTypeArgumentClose)
        }

        switch curTypes.count {
            case 0:
                return try _parseTypeTag(str: currentStr, types: innerTypes, allowGenerics: allowGenerics)
            case 1:
                if currentStr.isEmpty {
                    return curTypes[0]
                }
                throw ParseError(typeTagStr: typeStr, kind: .unexpectedComma)
            default:
                throw ParseError(typeTagStr: typeStr, kind: .unexpectedWhitespaceCharacter)
        }
    }
    
    private static func _parseTypeTag(str: String, types: [TypeTag], allowGenerics: Bool) throws -> TypeTag {
        switch str {
            case "&signer":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .Reference(.Signer)
            case "signer":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .Signer
            case "bool":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .Bool
            case "address":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .Address
            case "u8":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U8
            case "u16":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U16
            case "u32":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U32
            case "u64":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U64
            case "u128":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U128
            case "u256":
                if !types.isEmpty {
                    throw ParseError(typeTagStr: str, kind: .unexpectedPrimitiveTypeArguments)
                }
                return .U256
            case "vector":
                if types.count != 1 {
                    throw ParseError(typeTagStr: str, kind: .unexpectedVectorTypeArgumentCount)
                }
                return .Vector(types[0])
            default:
                if isGeneric(str) {
                    if allowGenerics {
                        return .Generic(UInt32(str.split(separator: "T")[1])!)
                    }
                    throw ParseError(typeTagStr: str, kind: .unexpectedGenericType)
                }
                if !str.contains(":") {
                    throw ParseError(typeTagStr: str, kind: .invalidTypeTag)
                }

                let structParts = str.split(separator: ":")
                if structParts.count != 3 {
                    throw ParseError(typeTagStr: str, kind: .unexpectedStructFormat)
                }
                
                if !isValidIdentifier(String(structParts[1])) {
                    throw ParseError(typeTagStr: str, kind: .invalidModuleNameCharacter)
                }
                if !isValidIdentifier(String(structParts[2])) {
                    throw ParseError(typeTagStr: str, kind: .invalidStructNameCharacter)
                }
                return .Struct(.init(address: try AccountAddress.fromString(String(structParts[0])), moduleName: Identifier(String(structParts[1])), name: Identifier(String(structParts[2])), typeArgs: types))
        }
    }
}