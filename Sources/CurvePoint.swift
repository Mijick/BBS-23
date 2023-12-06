//
//  CurvePoint.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

struct CurvePoint {
    let x: BInt
    let y: BInt
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(lhs: Self, rhs: Self) -> CurvePoint {
        addPoint(lhs, to: rhs)
//        let a = (rhs.y - lhs.y) / (rhs.x - lhs.x)
//
//        let x = a * a - lhs.x - rhs.x
//        let y = a * (lhs.x - x) - lhs.y
//        return .init(x: x, y: y)
    }
}

// MARK: - Point x Scalar
extension CurvePoint {
    static func *(lhs: Self, rhs: BInt) -> CurvePoint {
        if rhs == 0 { return .zero }
        if rhs == 1 { return lhs }
        if rhs % 2 == 1 { return lhs + lhs * (rhs - 1) }

        return lhs.double() * (rhs / 2)
    }
}
private extension CurvePoint {
    func double() -> CurvePoint {
        return doublePoint(self)
        let a = (3 * x * x) / (2 * y)

        let newX = a * a - 2 * x
        let newY = a * (x - newX) - y
        return .init(x: newX, y: newY)
    }
}

extension CurvePoint {
    static var zero: Self { .init(x: .init(0), y: .init(0)) }
}



func addPoint(_ p1: CurvePoint, to p2: CurvePoint) -> CurvePoint {
    let λ = modInverseP(p2.y - p1.y, p2.x - p1.x)
    let x3 = modP { λ * λ - p1.x - p2.x }
    let y3 = modP { λ * (p1.x - x3) - p1.y }
    return CurvePoint(x: x3, y: y3)
}
///  modInverseP
func modInverseP(_ v: BInt, _ w: BInt) -> BInt {
    return modularInverse(v, w, mod: BLS12_381_SHA_256().po)
}

func modularInverse(_ x: BInt, _ y: BInt, mod: BInt) -> BInt {
    let x = x > 0 ? x : x + mod
    let y = y > 0 ? y : y + mod

    let inverse = extendedEuclideanAlgorithm(z: y, a: mod)

    var result = (inverse * x) % mod

    let zero = BInt(0)
    if result < zero {
        result = result + mod
    }

    return result
}

private func extendedEuclideanAlgorithm(z: BInt, a: BInt) -> BInt {
    var i = a
    var j = z
    var y1 = BInt(1)
    var y2 = BInt(0)

    let zero = BInt(0)
    while j > zero {
        let (quotient, remainder) = division(i, j)

        let y = y2 - y1 * quotient

        i = j
        j = remainder
        y2 = y1
        y1 = y
    }

    return y2 % a
}

func division(_ a: BInt, _ b: BInt) -> (quotient: BInt, remainder: BInt) {
    return (a / b, a % b)
}

/// modP
func modP(_ expression: () -> BInt) -> BInt {
    expression().mod(BLS12_381_SHA_256().po)
    //return mod(expression(), modulus: P)
}



func doublePoint(_ p: CurvePoint) -> CurvePoint {
    let λ = modInverseP(3 * (p.x * p.x), 2 * p.y)

    let x3 = modP { λ * λ - 2 * p.x }
    let y3 = modP { λ * (p.x - x3) - p.y }

    return CurvePoint(x: x3, y: y3)
}


extension CurvePoint: Equatable {
    public static func == (lhs: CurvePoint, rhs: CurvePoint) -> Bool { lhs.x == rhs.x && lhs.y == rhs.y }
}
