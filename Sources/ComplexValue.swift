//
//  ComplexValue.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

struct ComplexValue {
    var real: BInt
    var imaginary: BInt?
}

// MARK: - Initialisers
extension ComplexValue: ExpressibleByArrayLiteral {
    init(_ realValue: BInt) { self.real = realValue }
    init?(_ realValue: BInt?) { guard let realValue else { return nil }; self.real = realValue }
    init(arrayLiteral elements: BInt...) { self.real = elements.get(0) ?? 0; self.imaginary = elements.get(1) }
}

// MARK: - Comparing Values
extension ComplexValue: Equatable {
    static func ==(v1: Self, v2: Self) -> Bool { v1.real == v2.real && v1.imaginary == v2.imaginary }
    static func >(v1: Self, v2: Self) -> Bool { v1.imaginary == v2.imaginary ? v1.real > v2.real : v1.imaginary > v2.imaginary }
}
extension ComplexValue? {
    static func >(lhs: ComplexValue?, rhs: ComplexValue?) -> Bool { rhs == nil ? true : lhs == nil ? false : lhs! > rhs! }
}

// MARK: - Arithmetic Operations
extension ComplexValue {
    static func +(v1: Self, v2: Self) -> Self { .init(real: v1.real + v2.real, imaginary: v1.imaginary + v2.imaginary) }
    static func +(v1: BInt, v2: Self) -> Self { .init(real: v1 + v2.real, imaginary: v2.imaginary) }
    static func -(v1: Self, v2: Self) -> Self { .init(real: v1.real - v2.real, imaginary: v1.imaginary - v2.imaginary) }
    static func -(v1: BInt, v2: Self) -> Self { .init(real: v1 - v2.real, imaginary: v2.imaginary) }

    static func *(v1: Self, v2: Self) -> Self { .init(real: v1.real * v2.real - v1.imaginary * v2.imaginary, imaginary: v1.real * v2.imaginary + v1.imaginary * v2.real) }
    static func *(v1: Self, v2: BInt) -> Self { .init(real: v1.real * v2, imaginary: v1.imaginary * v2) }
    static func *(v1: BInt, v2: Self) -> Self { .init(real: v1 * v2.real, imaginary: v1 * v2.imaginary) }

    static prefix func -(x: Self) -> Self { .init(real: -x.real, imaginary: -x.imaginary) }
}
extension ComplexValue? {
    static prefix func -(x: ComplexValue?) -> ComplexValue? { x == nil ? nil : -x! }
}

// MARK: - Others
extension ComplexValue {
    mutating func negate() { self = -self }
}
extension ComplexValue {
    func modInverse(_ m: BInt) -> ComplexValue {
        let divider = (real * real + imaginary * imaginary).modInverse(m)

        let real = real * divider
        let imaginary = (-1) * imaginary * divider
        return .init(real: real.mod(m), imaginary: imaginary?.mod(m))
    }
    func mod(_ x: BInt) -> ComplexValue { .init(real: real.mod(x), imaginary: imaginary?.mod(x)) }
    func sqrtMod(_ p: BInt) -> ComplexValue { .init(real: real.sqrtMod(p)!, imaginary: imaginary?.sqrtMod(p)) }
}
