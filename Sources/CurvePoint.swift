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
    private var _x: ComplexValue
    private var _y: ComplexValue!
    private let curve: CurveSuite
}

// MARK: - Initialisers
extension CurvePoint {
    // MARK: Real
    init(x: BInt, _ curve: CurveSuite) {
        self._x = .init(x)
        self._y = .init(curve.f([x]).sqrtMod(curve.p))
        self.curve = curve
    }
    init(x: BInt, y: BInt?, _ curve: CurveSuite) {
        self._x = .init(x)
        self._y = .init(y)
        self.curve = curve
    }

    // MARK: Complex
    init(xComplex: ComplexValue, _ curve: CurveSuite) {
        self._x = xComplex
        self._y = .init(curve.f(xComplex).sqrtMod(curve.p))
        self.curve = curve
    }
    init(xComplex: ComplexValue, yComplex: ComplexValue?, _ curve: CurveSuite) {
        self._x = xComplex
        self._y = yComplex
        self.curve = curve
    }
}

// MARK: - Initializers Helpers
extension CurvePoint {
    func modularized() -> CurvePoint { .init(xComplex: xComplex.mod(curve.p), yComplex: yComplex?.mod(curve.p), curve) }
}

// MARK: - Getters & Setters
extension CurvePoint {
    // MARK: Real
    var x: BInt {
        get { _x.real }
        set { _x.real = newValue }
    }
    var y: BInt! {
        get { _y?.real }
        set { if _y == nil || newValue == nil { _y = nil } else { _y!.real = newValue! } }
    }

    // MARK: Complex
    var xComplex: ComplexValue {
        get { _x }
        set { _x = newValue }
    }
    var yComplex: ComplexValue! {
        get { _y }
        set { _y = newValue }
    }
}

// MARK: - Comparing Points
extension CurvePoint: Equatable {
    static func ==(p1: CurvePoint, p2: CurvePoint) -> Bool { p1.xComplex == p2.xComplex && p1.yComplex == p2.yComplex }
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(p1: Self, p2: Self) -> CurvePoint { let p1 = p1.modularized(), p2 = p2.modularized(), curve = p1.curve, p = curve.p
        if p1.isAtInfinity() || p2.isAtInfinity() { return .init(xComplex: [], yComplex: nil, curve) }

        let λ = addCalculateLambda(p1, p2, p)
        let x = addCalculateX(p1, p2, λ, p)
        let y = addCalculateY(p1, x, λ, p)

        let point = CurvePoint(xComplex: x, yComplex: y, curve)
        return point.modularized()
    }
}
private extension CurvePoint {
    static func addCalculateLambda(_ p1: Self, _ p2: Self, _ p: BInt) -> ComplexValue {
        let lλ = (p2.yComplex - p1.yComplex).mod(p)
        let rλ = (p2.xComplex - p1.xComplex).modInverse(p)

        return (lλ * rλ).mod(p)
    }
    static func addCalculateX(_ p1: Self, _ p2: Self, _ λ: ComplexValue, _ p: BInt) -> ComplexValue {
        let λ² = (λ * λ).mod(p)
        return λ² - p1.xComplex - p2.xComplex
    }
    static func addCalculateY(_ p1: Self, _ x: ComplexValue, _ λ: ComplexValue, _ p: BInt) -> ComplexValue {
        let lr = (p1.xComplex - x).mod(p)
        let l = (λ * lr).mod(p)

        return l - p1.yComplex
    }
}

// MARK: - Point x Scalar
extension CurvePoint {
    static func *(point: Self, scalar: BInt) -> CurvePoint {
        if point.isAtInfinity() { return .init(xComplex: [], yComplex: nil, point.curve) }
        if scalar == 0 { return .init(xComplex: [], yComplex: [], point.curve) }
        if scalar == 1 { return point }
        if scalar % 2 == 1 { return point + point * (scalar - 1) }

        return point.double() * (scalar / 2)
    }
    static func *(scalar: BInt, point: Self) -> CurvePoint { point * scalar }
}
private extension CurvePoint {
    func double() -> CurvePoint { let p = curve.p, xComplex = xComplex.mod(p), yComplex = yComplex.mod(p)
        let λ = doubleCalculateLambda(xComplex, yComplex, p)
        let x = doubleCalculateX(xComplex, λ, p)
        let y = doubleCalculateY(xComplex, yComplex, x, λ, p)

        let point = CurvePoint(xComplex: x, yComplex: y, curve)
        return point.modularized()
    }
}
private extension CurvePoint {
    func doubleCalculateLambda(_ xComplex: ComplexValue, _ yComplex: ComplexValue, _ p: BInt) -> ComplexValue {
        let lλ = (3 * xComplex * xComplex).mod(curve.p)
        let rλ = (2 * yComplex).modInverse(curve.p)

        return (lλ * rλ).mod(p)
    }
    func doubleCalculateX(_ xComplex: ComplexValue, _ λ: ComplexValue, _ p: BInt) -> ComplexValue {
        let λ² = (λ * λ).mod(p)
        return λ² - 2 * xComplex
    }
    func doubleCalculateY(_ xComplex: ComplexValue, _ yComplex: ComplexValue, _ x: ComplexValue, _ λ: ComplexValue, _ p: BInt) -> ComplexValue {
        let lr = xComplex - x
        let l = (λ * lr).mod(p)

        return l - yComplex
    }
}

// MARK: - Others
extension CurvePoint {
    func isAtInfinity() -> Bool { y == nil }
    func isPointOfG1() -> Bool { curve is Curve.BLS12_381_G1 }
    func isPointOfG2() -> Bool { curve is Curve.BLS12_381_G2 }
}
