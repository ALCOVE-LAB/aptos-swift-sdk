//
//  File.swift
//  
//
//  Created by wanglei on 2024/5/7.
//

import Foundation
import OpenAPIRuntime

// TOOD:, move imp to public types module

public typealias MoveStructValue = OpenAPIRuntime.OpenAPIObjectContainer
public typealias MoveStructTag = String

public struct MoveResource: Codable, Hashable, Sendable {
    public var type: MoveStructTag
    public var data: MoveStructValue
    
    public enum CodingKeys: String, CodingKey {
        case type = "type"
        case data
    }
}


public typealias HexEncodedBytes = String
public typealias IdentifierWrapper = String
public typealias MoveModuleId = String
public typealias MoveType = String

public struct MoveModuleBytecode: Codable, Hashable, Sendable {
    public var bytecode: String
    public var abi: MoveModule?
  
    public enum CodingKeys: String, CodingKey {
        case bytecode
        case abi
    }
}

public struct MoveModule: Codable, Hashable, Sendable {
    public var address: String
    
    public var name: String
    
    public var friends: [MoveModuleId]
    
    public var exposed_functions: [MoveFunction]
    
    public var structs: [MoveStruct]
    
    public enum CodingKeys: String, CodingKey {
        case address
        case name
        case friends
        case exposed_functions
        case structs
    }
}

public struct MoveFunction: Codable, Hashable, Sendable {
   
    public var name: String
   
    public var visibility: MoveFunctionVisibility
    public var isEntry: Bool

    public var isView: Bool
 
    public var genericTypeParams: [MoveFunctionGenericTypeParam]
    public var params: [MoveType]
   
    public var `return`: [MoveType]
  
    public enum CodingKeys: String, CodingKey {
       case name
       case visibility
       case isEntry = "is_entry"
       case isView  = "is_view"
       case genericTypeParams = "generic_type_params"
       case params
       case `return` = "return"
   }
}

public struct MoveStruct: Codable, Hashable, Sendable {
    public var name: String
    
    public var isNative: Swift.Bool
  
    public var abilities: [MoveAbility]
   
    public var genericTypeParams: [MoveStructGenericTypeParam]
  
    public var fields: [MoveStructField]
    
    public enum CodingKeys: String, CodingKey {
        case name
        case isNative = "is_native"
        case abilities
        case genericTypeParams = "generic_type_params"
        case fields
    }
}

public enum MoveFunctionVisibility: String, Codable, Hashable, Sendable {
    case `private` = "private"
    case `public` = "public"
    case friend = "friend"
}

public enum MoveAbility: String, Codable, Hashable, Sendable {
    case store
    case drop
    case key
    case copy
}

public struct MoveFunctionGenericTypeParam: Codable, Hashable, Sendable {
   public var constraints: [MoveAbility]
   
   internal enum CodingKeys: String, CodingKey {
       case constraints
   }
}

public struct MoveStructGenericTypeParam: Codable, Hashable, Sendable {
   
    public var constraints: [MoveAbility]
   
   public enum CodingKeys: String, CodingKey {
       case constraints
   }
}

public struct MoveStructField: Codable, Hashable, Sendable {
    
    public var name: String
    public var `type`: MoveType
    
    public enum CodingKeys: String, CodingKey {
        case name
        case type = "type"
    }
}
