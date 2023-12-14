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
    static func -(v1: BInt, v2: Self) -> Self { v1 + (-v2) }
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
    func sqrtMod(_ p: BInt) -> ComplexValue {
        // MARK: Pre-calculated
        let c1 = (p - 3) * BInt(4).modInverse(p),
            c2 = (p - 1) * BInt(2).modInverse(p)

        // MARK: Temporary Values
        let tv1 = exp(c1, p)
        let tv2 = tv1 * tv1 * self
        let tv3 = ([1, 0] + tv2).exp(c2, p)
        let tv4 = tv1 * self

        // MARK: Calculating Value
        let neg = ComplexValue(real: -1, imaginary: 0).mod(p)

        switch tv2 == neg {
            case true: return [0, 1] * tv4
            case false: return tv3 * tv4
        }
    }




    func exp(_ k: BInt, _ mod: BInt) -> ComplexValue {
        var c: ComplexValue = [1, 0]

        let bits = Array(Array(k.mod(mod).asString(radix: 2)).reversed())


        for i in 0..<381 {
            c = (c * c).mod(mod)


            if bits.count > 380 - i && bits[380 - i] == "1" {
                c = (c * self).mod(mod)
            }

        }

        return c



    }
}
