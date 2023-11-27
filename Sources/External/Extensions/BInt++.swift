//
//  BInt++.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

// MARK: - Initialisers
extension BInt: ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
    public init(integerLiteral value: Int) { self.init(value) }
    public init(stringLiteral value: StringLiteralType) { self.init(hex: value) }
    init(hex value: String) { self.init(value, radix: 16)! }
}

// MARK: - Helpers
extension BInt {
    func toBytes(expectedLength: Int) throws -> [UInt8] { try Primitives.integerToBytes(value: self, expectedLength: expectedLength) }
}
