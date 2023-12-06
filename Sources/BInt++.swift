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

extension BInt {
    init(decimal value: String) { self.init(value, radix: 10)! }
    init(hex value: String) { self.init(value, radix: 16)! }
}

extension BInt: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self.init(value) }
}
