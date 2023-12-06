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
    let curve: CurveSuite
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(lhs: Self, rhs: Self) -> CurvePoint {
        addPoint(lhs, to: rhs)
    }
}

// MARK: - Point x Scalar
extension CurvePoint {
    static func *(lhs: Self, rhs: BInt) -> CurvePoint {
        if rhs == 0 { return .init(x: 0, y: 0, curve: lhs.curve) }
        if rhs == 1 { return lhs }
        if rhs % 2 == 1 { return lhs + lhs * (rhs - 1) }

        return lhs.double() * (rhs / 2)
    }
}
private extension CurvePoint {
    func double() -> CurvePoint {
        let λ = (3 * x * x) * (2 * y).modInverse(curve.p)

        let x3 = λ * λ - 2 * x
        let y3 = λ * (x - x3) - y

        return CurvePoint(x: x3.mod(curve.p), y: y3.mod(curve.p), curve: curve)
    }
}



func addPoint(_ p1: CurvePoint, to p2: CurvePoint) -> CurvePoint {
    let p = Cipher.BLS12_381_SHA_256().curve.p





    let λ = (p2.y - p1.y) * (p2.x - p1.x).modInverse(p)
    let x3 = λ * λ - p1.x - p2.x
    let y3 = λ * (p1.x - x3) - p1.y
    return CurvePoint(x: x3.mod(p), y: y3.mod(p), curve: p1.curve)
}


extension CurvePoint: Equatable {
    static func == (lhs: CurvePoint, rhs: CurvePoint) -> Bool { lhs.x == rhs.x && lhs.y == rhs.y }
}
