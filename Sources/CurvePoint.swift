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

struct CurvePoint<F: Field> {
    var x: F
    var y: F!

    init(x: F, y: F?) { self.x = x; self.y = y }
}

// MARK: - Initializers Helpers
extension CurvePoint {
    func modularized() -> CurvePoint { .init(x: x.mod(), y: y?.mod()) }
}

// MARK: - Comparing Points
extension CurvePoint: Equatable {
    static func == (p1: CurvePoint, p2: CurvePoint) -> Bool { p1.x == p2.x && p1.y == p2.y }
}

// MARK: - Points Addition
extension CurvePoint {
    static func + (p1: Self, p2: Self) -> Self {
        if p1.isAtInfinity() || p2.isAtInfinity() { return .init(x: 0, y: nil) }

        let λ = addCalculateLambda(p1, p2)
        let x = addCalculateX(p1, p2, λ)
        let y = addCalculateY(p1, x, λ)

        let point = CurvePoint(x: x, y: y)
        return point.modularized()
    }
}
private extension CurvePoint {
    static func addCalculateLambda(_ p1: Self, _ p2: Self) -> F { (p2.y - p1.y) * ((p2.x - p1.x).modInverse()) }
    static func addCalculateX(_ p1: Self, _ p2: Self, _ λ: F) -> F { (λ * λ) - p1.x - p2.x }
    static func addCalculateY(_ p1: Self, _ x: F, _ λ: F) -> F { λ * (p1.x - x) - p1.y }
}

// MARK: - Point x Scalar
extension CurvePoint {
    static func * (point: Self, scalar: BInt) -> CurvePoint {
        if point.isAtInfinity() { return .init(x: 0, y: nil) }
        if scalar == 0 { return .init(x: 0, y: 0) }
        if scalar == 1 { return point }
        if scalar % 2 == 1 { return point + point * (scalar - 1) }

        return point.double() * (scalar / 2)
    }
    static func * (scalar: BInt, point: Self) -> CurvePoint { point * scalar }
}
private extension CurvePoint {
    func double() -> CurvePoint {
        let λ = doubleCalculateLambda(x, y)
        let newX = doubleCalculateX(x, λ)
        let newY = doubleCalculateY(newX, λ)

        let point = CurvePoint(x: newX, y: newY)
        return point.modularized()
    }
}
private extension CurvePoint {
    func doubleCalculateLambda(_ x: F, _ y: F) -> F { (3 * x * x) * ((2 * y).modInverse()) }
    func doubleCalculateX(_ x: F, _ λ: F) -> F { (λ * λ) - 2 * x }
    func doubleCalculateY(_ newX: F, _ λ: F) -> F { λ * (x - newX) - y }
}

// MARK: - Points Substraction
extension CurvePoint {
    static func - (p1: Self, p2: Self) -> CurvePoint { p1 + (-p2) }
}
extension CurvePoint {
    static prefix func - (p: CurvePoint) -> CurvePoint { .init(x: p.x, y: -p.y).modularized() }
}

// MARK: - Others
extension CurvePoint {
    func isAtInfinity() -> Bool { y == nil }
}
