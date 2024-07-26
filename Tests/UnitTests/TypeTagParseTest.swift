import XCTest
import Transactions
import Core
import Utils

class TypeTagParseTest: XCTestCase {

    func structTagType(_ typeTags: [TypeTag] = []) -> TypeTag {
        TypeTag.Struct(
            .init(
                address: AccountAddress.ONE,
                moduleName: Identifier("tag"),
                name: Identifier("Tag"),
                typeArgs: typeTags
            )
        )
    }

    func testInvalidTypes() throws {
        try [
            "8": TypeTag.ParseError.ErrorKind.invalidTypeTag,
            
            "addr": .invalidTypeTag,
            "&address": .invalidTypeTag,
            "T1": .unexpectedGenericType,

            "0x1:tag::Tag": .unexpectedStructFormat,
            "0x1::tag:Tag": .unexpectedStructFormat,

            "0x1::tag::Tag<8>": .invalidTypeTag,
            "0x1::tag::Tag <u8>": .unexpectedWhitespaceCharacter,
            "0x1::tag::Tag<<u8 u8": .unexpectedWhitespaceCharacter,
            "0x1::tag::Tag<<u8": .missingTypeArgumentClose,
            "0x1::tag::Tag<u8>>": .unexpectedTypeArgumentClose,

            "u8, u8": .unexpectedComma,
            "u8,u8": .unexpectedComma,
            "u8 ,u8": .unexpectedComma,

            "0x1::tag::Tag<u8>,0x1::tag::Tag": .unexpectedComma,
            "0x1::tag::Tag<u8>, 0x1::tag::Tag": .unexpectedComma,
            "0x1::tag::Tag<u8> ,0x1::tag::Tag": .unexpectedComma,
            "0x1::tag::Tag<u8> , 0x1::tag::Tag": .unexpectedComma,

            "0x1::tag::Tag<u8<u8>>": .unexpectedPrimitiveTypeArguments,
            "0x1::tag::Tag<u8><u8>": .unexpectedPrimitiveTypeArguments,
            "0x1<u8>::tag::Tag<u8>": .unexpectedPrimitiveTypeArguments,
            "0x1::tag<u8>::Tag<u8>": .unexpectedPrimitiveTypeArguments,

            "0x1::tag::Tag<>": .typeArgumentCountMismatch,
            "0x1::tag::Tag<,>": .typeArgumentCountMismatch,
            "0x1::tag::Tag<, >": .typeArgumentCountMismatch,
            "0x1::tag::Tag< ,>": .typeArgumentCountMismatch,
            "0x1::tag::Tag< , >": .typeArgumentCountMismatch,
            "0x1::tag::Tag<u8,>": .typeArgumentCountMismatch,
            "0x1::tag::Tag<0x1::tag::Tag<>>>": .typeArgumentCountMismatch,
            "0x1::tag::Tag<0x1::tag::Tag<u8,>>>": .typeArgumentCountMismatch,

            "0x1::tag::Tag<0x1::tag::Tag<,u8>>>": .unexpectedTypeArgumentClose,
        ].forEach( {key, errorKind in 
            XCTAssertThrowsError(try TypeTag.parseTypeTag(key)) { error in
                guard let error = error as? TypeTag.ParseError else {
                    XCTFail("Expected TypeTag.ParseError")
                    return
                }
                XCTAssertEqual(error.kind, errorKind)
            }
        }
      )

      try [
        "0x1::tag::Tag<8>": TypeTag.ParseError.init(typeTagStr: "8", kind: .invalidTypeTag),
        "0x1::tag::Tag<u8<u8>>": .init(typeTagStr: "u8", kind: .unexpectedPrimitiveTypeArguments),
        "0x1::tag::Tag<u8><u8>": .init(typeTagStr: "u8", kind: .unexpectedPrimitiveTypeArguments),
        "0x1<u8>::tag::Tag<u8>": .init(typeTagStr: "u8", kind: .unexpectedPrimitiveTypeArguments),
      ].forEach( {key, value in 
            XCTAssertThrowsError(try TypeTag.parseTypeTag(key)) { error in
                guard let error = error as? TypeTag.ParseError else {
                    XCTFail("Expected TypeTag.ParseError")
                    return
                }
                XCTAssertEqual(error, value)
            }
        }
      )
    }

    func testStandardTypes() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("signer"), .Signer)
      XCTAssertEqual(try TypeTag.parseTypeTag("&signer"), .Reference(.Signer))
      XCTAssertEqual(try TypeTag.parseTypeTag("u8"), .U8)
      XCTAssertEqual(try TypeTag.parseTypeTag("u16"), .U16)
      XCTAssertEqual(try TypeTag.parseTypeTag("u32"), .U32)
      XCTAssertEqual(try TypeTag.parseTypeTag("u64"), .U64)
      XCTAssertEqual(try TypeTag.parseTypeTag("u128"), .U128)
      XCTAssertEqual(try TypeTag.parseTypeTag("u256"), .U256)
      XCTAssertEqual(try TypeTag.parseTypeTag("bool"), .Bool)
      XCTAssertEqual(try TypeTag.parseTypeTag("address"), .Address)
    }

    func testGenericTypesWithAllowGenericsOn() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("T0", allowGenerics: true), .Generic(0))
      XCTAssertEqual(try TypeTag.parseTypeTag("T1", allowGenerics: true), .Generic(1))
      XCTAssertEqual(try TypeTag.parseTypeTag("T1337", allowGenerics: true), .Generic(1337))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<T0>", allowGenerics: true), .Vector(.Generic(0)))
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<T0, T1>", allowGenerics: true), structTagType([.Generic(0), .Generic(1)]))
    }

    func testOutsideSpacing() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag(" address"), .Address)
      _ = try TypeTag.parseTypeTag("address ")
      XCTAssertEqual(try TypeTag.parseTypeTag("address "), .Address)
      XCTAssertEqual(try TypeTag.parseTypeTag(" address "), .Address)
    }

    func testVector() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u8>"), .Vector(.U8))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u16>"), .Vector(.U16))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u32>"), .Vector(.U32))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u64>"), .Vector(.U64))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u128>"), .Vector(.U128))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<u256>"), .Vector(.U256))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<bool>"), .Vector(.Bool))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<address>"), .Vector(.Address))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<0x1::string::String>"), .Vector((.Struct(.string))))
    }

    func testNestedVector() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u8>>"), .Vector(.Vector(.U8)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u16>>"), .Vector(.Vector(.U16)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u32>>"), .Vector(.Vector(.U32)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u64>>"), .Vector(.Vector(.U64)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u128>>"), .Vector(.Vector(.U128)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<u256>>"), .Vector(.Vector(.U256)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<bool>>"), .Vector(.Vector(.Bool)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<address>>"), .Vector(.Vector(.Address)))
      XCTAssertEqual(try TypeTag.parseTypeTag("vector<vector<0x1::string::String>>"), .Vector(.Vector(.Struct(.string))))
    }

    func testAptosCoin() throws {
      let aptosCoin = TypeTag.Struct(.aptosCoin)
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::aptos_coin::AptosCoin"), aptosCoin)
      XCTAssertEqual(try TypeTag.parseTypeTag(APTOS_COIN), aptosCoin)
    }

    func testString() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::string::String"), .Struct(.string))
    }

    func testObject() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::object::Object<0x1::tag::Tag>"), .Struct(.object(structTagType())))
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::object::Object<0x1::tag::Tag<u8>>"), .Struct(.object(structTagType([.U8]))))
    }

    func testOption() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::option::Option<0x1::tag::Tag>"), .Struct(.option(structTagType())))
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::option::Option<0x1::tag::Tag<u8>>"), .Struct(.option(structTagType([.U8]))))
    }

    func testTags() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag"), structTagType())

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<u8>"), structTagType([.U8]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<u8,u64>"), structTagType([.U8, .U64]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<u8,  u8>"), structTagType([.U8, .U8]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<  u8,u8>"), structTagType([.U8, .U8]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<u8,u8  >"), structTagType([.U8, .U8]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<0x1::tag::Tag<u8>>"), structTagType([structTagType([.U8])]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<0x1::tag::Tag<u8, u8>>"), structTagType([structTagType([.U8, .U8])]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<u8, 0x1::tag::Tag<u8>>"), structTagType([.U8, structTagType([.U8])]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<0x1::tag::Tag<u8>, u8>"), structTagType([structTagType([.U8]), .U8]))

      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<0x1::tag::Tag<0x1::tag::Tag<u8>>, u8>"), structTagType([structTagType([structTagType([.U8])]), .U8]))
    }

    func testStructWithGeneric() throws {
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<T0>", allowGenerics: true), structTagType([.Generic(0)]))
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<T0, T1>", allowGenerics: true), structTagType([.Generic(0), .Generic(1)]))
      XCTAssertEqual(try TypeTag.parseTypeTag("0x1::tag::Tag<0x1::tag::Tag<T0, T1>, T2>", allowGenerics: true), structTagType([structTagType([.Generic(0), .Generic(1)]), .Generic(2)]))
    }
}
