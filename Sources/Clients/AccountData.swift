//
//  File.swift
//  
//
//  Created by wanglei on 2024/5/7.
//

import Foundation

public struct AccountData: Codable, Hashable, Sendable {
    /// - Remark: Generated from `#/components/schemas/AccountData/sequence_number`.
    internal var sequence_number: U64
    /// - Remark: Generated from `#/components/schemas/AccountData/authentication_key`.
    internal var authentication_key: HexEncodedBytes
    /// Creates a new `AccountData`.
    ///
    /// - Parameters:
    ///   - sequence_number:
    ///   - authentication_key:
    internal init(
        sequence_number: U64,
        authentication_key: HexEncodedBytes
    ) {
        self.sequence_number = sequence_number
        self.authentication_key = authentication_key
    }
    internal enum CodingKeys: String, CodingKey {
        case sequence_number
        case authentication_key
    }
}

typealias U64 = String
typealias HexEncodedBytes = String

