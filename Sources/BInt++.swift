//
//  BInt++.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

// MARK: - Initialisers
extension BInt: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self.init(value) }
    init(decimal value: String) { self.init(value, radix: 10)! }
    init(hex value: String) { self.init(value, radix: 16)! }
}

// MARK: - Helpers
extension BInt {
    func toBytes(expectedLength: Int) throws -> [UInt8] { try Primitives.integerToBytes(value: self, expectedLength: expectedLength) }
}


// MARK: - Comparing Values
extension BInt? {
    static func >(lhs: BInt?, rhs: BInt?) -> Bool { rhs == nil ? true : lhs == nil ? false : lhs! > rhs! }
}

// MARK: - Arithmetic Operations
extension BInt? {
    static func +(v1: BInt?, v2: BInt?) -> BInt? { v1 == nil || v2 == nil ? nil : v1! + v2! }
    static func +(v1: BInt, v2: BInt?) -> BInt { v1 + (v2 ?? 0) }

    static func -(v1: BInt?, v2: BInt?) -> BInt? { v1 == nil || v2 == nil ? nil : v1! - v2! }
    static func -(v1: BInt, v2: BInt?) -> BInt { v1 - (v2 ?? 0) }

    static func *(v1: BInt?, v2: BInt?) -> BInt? { v1 == nil || v2 == nil ? nil : v1! * v2! }
}
extension BInt? {
    static prefix func -(x: BInt?) -> BInt? { x == nil ? nil : -x! }
}
