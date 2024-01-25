//
//  Field.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

protocol Field: Equatable, ExpressibleByIntegerLiteral, ExpressibleByArrayLiteral, CustomStringConvertible {
    static func + (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: BInt) -> Self

    func mod() -> Self
    func modInverse() -> Self
    func mulNonRes() -> Self
    func exp(_ x: BInt) -> Self
    func squareRoot() -> Self

    init(_ v: [BInt])
}

// MARK: - Other Operations
extension Field {
    init(integerLiteral value: Int) { self.init([BInt(value)]) }
    init(_ v: BInt...) { self.init(Array(v)) }

    static func * (lhs: BInt, rhs: Self) -> Self { rhs * lhs }
    static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }
    static prefix func - (x: Self) -> Self { x * (-1) }
}
extension Field {
    func pow(_ exp: BInt, _ result: Self) -> Self {
        if exp <= 1 { return self }

        let accum = pow(exp >> 1, result)
        let accum² = accum * accum
        return exp.isEven ? accum² : accum² * self
    }
}

// MARK: - Helpers
extension Field {
    var p: BInt { BBSSettings.ciphersuite.p }
    var r: BInt { BBSSettings.ciphersuite.r }
}
