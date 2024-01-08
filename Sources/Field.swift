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

protocol Field: Equatable {
    var primeField: BInt { get }

    static func + (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: BInt) -> Self

    func modInverse() -> Self
    func mulNonRes() -> Self
}
extension Field {
    static func * (lhs: BInt, rhs: Self) -> Self { rhs * lhs }
    static func - (lhs: Self, rhs: Self) -> Self { lhs + (-rhs) }
    static prefix func - (x: Self) -> Self { x * (-1) }
}
