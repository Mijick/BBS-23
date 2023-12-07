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

// MARK: - Point On Curve
extension CurvePoint {
    func isOnBasicCurve() -> Bool {
        fatalError()
    }
    func isOnPrimeCurve() -> Bool {
        fatalError()
    }
}

// MARK: - Point At Infinity
extension CurvePoint {
    func isAtInfinity() -> Bool {
        isAtInfinityOnBasicCurve() || isAtInfinityOnPrimeCurve()
    }
    func isAtInfinityOnBasicCurve() -> Bool {
        fatalError()
    }
    func isAtInfinityOnPrimeCurve() -> Bool {
        fatalError()
    }
}

// MARK: - Comparing Points
extension CurvePoint: Equatable {
    static func == (p1: CurvePoint, p2: CurvePoint) -> Bool { p1.x == p2.x && p1.y == p2.y }
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(p1: Self, p2: Self) -> CurvePoint {
        let curve = p1.curve, p = curve.p
        let λ = (p2.y - p1.y) * (p2.x - p1.x).modInverse(p)

        let x3 = λ * λ - p1.x - p2.x
        let y3 = λ * (p1.x - x3) - p1.y
        return CurvePoint(x: x3.mod(p), y: y3.mod(p), curve: curve)
    }
}

// MARK: - Point x Scalar
extension CurvePoint {
    static func *(point: Self, scalar: BInt) -> CurvePoint {
        if scalar == 0 { return .init(x: 0, y: 0, curve: point.curve) }
        if scalar == 1 { return point }
        if scalar % 2 == 1 { return point + point * (scalar - 1) }

        return point.double() * (scalar / 2)
    }
}
private extension CurvePoint {
    func double() -> CurvePoint {
        let λ = (3 * x * x) * (2 * y).modInverse(p)

        let x3 = λ * λ - 2 * x
        let y3 = λ * (x - x3) - y

        return CurvePoint(x: x3.mod(p), y: y3.mod(p), curve: curve)
    }
}

// MARK: - Helpers
private extension CurvePoint {
    var p: BInt { curve.p }
}
