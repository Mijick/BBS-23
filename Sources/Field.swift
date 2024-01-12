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

protocol Field: Equatable, ExpressibleByIntegerLiteral {
    static func + (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: BInt) -> Self

    func mod() -> Self
    func modInverse() -> Self
    func mulNonRes() -> Self
    func exp(_ x: BInt) -> Self
    func squareRoot() -> Self
}

// MARK: - Other Operations
extension Field {
    static func * (lhs: BInt, rhs: Self) -> Self { rhs * lhs }
    static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }
    static prefix func - (x: Self) -> Self { x * (-1) }
}

// MARK: - Helpers
extension Field {
    var p: BInt {


        // TODO: Change it back
        .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")


    //    BBSSettings.ciphersuite.p


    }
}
