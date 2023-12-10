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
    private var _x: Value
    private var _y: Value!
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
    init(xComplex: Value, _ curve: CurveSuite) {
        self._x = xComplex
        self._y = .init(curve.f(xComplex).sqrtMod(curve.p))
        self.curve = curve
    }
    init(xComplex: Value, yComplex: Value?, _ curve: CurveSuite) {
        self._x = xComplex
        self._y = yComplex
        self.curve = curve
    }
}

// MARK: - Getters & Setters
extension CurvePoint {
    // MARK: Real
    var x: BInt {
        get { _x.real }
        set { _x.real = newValue }
    }
    var y: BInt! {
        get { _y.real }
        set { _y.real = newValue }
    }

    // MARK: Complex
    var xComplex: Value {
        get { _x }
        set { _x = newValue }
    }
    var yComplex: Value! {
        get { _y }
        set { _y = newValue }
    }
}

// MARK: - Comparing Points
extension CurvePoint: Equatable {
    static func == (p1: CurvePoint, p2: CurvePoint) -> Bool { p1.x == p2.x && p1.y == p2.y }
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(p1: Self, p2: Self) -> CurvePoint {
        if p1.isAtInfinity() || p2.isAtInfinity() { return .init(xComplex: [], yComplex: nil, p1.curve) }

        let curve = p1.curve, p = curve.p
        let λ = (p2.yComplex - p1.yComplex) * (p2.xComplex - p1.xComplex).modInverse(p)

        let x3 = λ * λ - p1.xComplex - p2.xComplex
        let y3 = λ * (p1.xComplex - x3) - p1.yComplex
        return .init(xComplex: x3.mod(p), yComplex: y3.mod(p), curve)
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
}
private extension CurvePoint {
    func double() -> CurvePoint {
        let λ = (3 * xComplex * xComplex) * (2 * yComplex).modInverse(curve.p)

        let x3 = λ * λ - 2 * xComplex
        let y3 = λ * (xComplex - x3) - yComplex

        return CurvePoint(xComplex: x3.mod(curve.p), yComplex: y3.mod(curve.p), curve)
    }
}

// MARK: - Others
extension CurvePoint {
    func isAtInfinity() -> Bool { y == nil }
}



struct Value {
    var real: BInt
    var imaginary: BInt?
}

// MARK: - Initialisers
extension Value: ExpressibleByArrayLiteral {
    init(_ realValue: BInt) { self.real = realValue }
    init?(_ realValue: BInt?) { guard let realValue else { return nil }; self.real = realValue }
    init(arrayLiteral elements: BInt...) { self.real = elements.get(0) ?? 0; self.imaginary = elements.get(1) }
}

// MARK: - Comparing Values
extension Value: Equatable {
    static func ==(v1: Self, v2: Self) -> Bool { v1.real == v2.real && v1.imaginary == v2.imaginary }
}

// MARK: - Arithmetic Operations
extension Value {
    static func +(v1: Self, v2: Self) -> Self { .init(real: v1.real + v2.real, imaginary: v1.imaginary + v2.imaginary) }
    static func -(v1: Self, v2: Self) -> Self { .init(real: v1.real - v2.real, imaginary: v1.imaginary - v2.imaginary) }
    static func *(v1: Self, v2: Self) -> Self { .init(real: v1.real * v2.real, imaginary: v1.imaginary * v2.imaginary) }

    static func *(v1: Self, v2: BInt) -> Self { .init(real: v1.real * v2, imaginary: v1.imaginary) }
    static func *(v1: BInt, v2: Self) -> Self { .init(real: v1 * v2.real, imaginary: v2.imaginary) }

    static prefix func -(x: Self) -> Self { .init(real: -x.real, imaginary: -x.imaginary) }
}

// MARK: - Others
extension Value {
    func modInverse(_ m: BInt) -> Value { .init(real: real.modInverse(m), imaginary: imaginary?.modInverse(m)) }
    func mod(_ x: BInt) -> Value { .init(real: real.mod(x), imaginary: imaginary?.mod(x)) }
    func sqrtMod(_ p: BInt) -> Value { .init(real: real.sqrtMod(p)!, imaginary: imaginary?.sqrtMod(p)!) }
}
