//
//  Point.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Point<F: Field> {
    let x: F
    let y: F
    let curve: any CurveSuite
}


extension Point where F == Fq2 {
    func untwist() -> Point<Fq12> {
        let root = Fq6(v0: 0, v1: 1, v2: 0)

        let ax = Fq12(w0: [[x.u0.t0], [x.u1.t0]], w1: 0)
        let bx = Fq12(w0: root, w1: 0).modInverse()

        let aY = Fq12(w0: [[y.u0.t0, y.u1.t0]], w1: 0)
        let bY = Fq12(w0: 0, w1: root).modInverse()

        return .init(x: ax * bx, y: aY * bY, curve: curve)
    }
}
















// MARK: - Double Eval
extension Fq12 {
    static func doubleEval(_ p: Point<Fq1>, _ r: Point<Fq2>) -> Fq12 {
        let wideR = r.untwist()
        let slope = (3 * (wideR.x * wideR.x)) * (2 * wideR.y).modInverse()
        let v = wideR.y - slope * wideR.x



//        let p1 = Fq12(
//            .init([[p.y.t0]]),
//            .init([[0]]),
//            p.primeField
//        )
//        let p2 = createFq12(
//            createFq6([p.x.t0]),
//            createFq6([0])
//        ) * slope



        fatalError()
    }
}


// MARK: - Add Eval
extension Fq12 {
    static func addEval(_ p: Point<Fq1>, q: Point<Fq2>, r: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}
private extension Fq12 {

}


// MARK: - Miller
extension Fq12 {
    static func miller(_ p: Point<Fq1>, q: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}

// MARK: - Pairing
extension Fq12 {
    static func pairing(_ pG1: Point<Fq1>, pG2: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}



extension Fq12 {
    static func pair(pG1: CurvePoint, pG2: CurvePoint) -> Fq12 {
        fatalError()
    }
}






struct NewPoint<F: Field> {
    var x: F
    var y: F!
}

// MARK: - Initializers Helpers
extension NewPoint {
    func modularized() -> NewPoint { .init(x: x.mod(), y: y?.mod()) }
}

// MARK: - Comparing Points
extension NewPoint: Equatable {
    static func == (p1: NewPoint, p2: NewPoint) -> Bool { p1.x == p2.x && p1.y == p2.y }
}

// MARK: - Points Addition
extension NewPoint {
    static func + (p1: Self, p2: Self) -> Self {
        if p1.isAtInfinity() || p2.isAtInfinity() { return .init(x: 0, y: nil) }

        let λ = addCalculateLambda(p1, p2)
        let x = addCalculateX(p1, p2, λ)
        let y = addCalculateY(p1, x, λ)

        let point = NewPoint(x: x, y: y)
        return point.modularized()
    }
}
private extension NewPoint {
    static func addCalculateLambda(_ p1: Self, _ p2: Self) -> F { (p2.y - p1.y) * ((p2.x - p1.x).modInverse()) }
    static func addCalculateX(_ p1: Self, _ p2: Self, _ λ: F) -> F { (λ * λ) - p1.x - p2.x }
    static func addCalculateY(_ p1: Self, _ x: F, _ λ: F) -> F { λ * (p1.x - x) - p1.y }
}

// MARK: - Point x Scalar
extension NewPoint {
    static func * (point: Self, scalar: BInt) -> NewPoint {
        if point.isAtInfinity() { return .init(x: 0, y: nil) }
        if scalar == 0 { return .init(x: 0, y: 0) }
        if scalar == 1 { return point }
        if scalar % 2 == 1 { return point + point * (scalar - 1) }

        return point.double() * (scalar / 2)
    }
    static func * (scalar: BInt, point: Self) -> NewPoint { point * scalar }
}
private extension NewPoint {
    func double() -> NewPoint {
        let λ = doubleCalculateLambda(x, y)
        let newX = doubleCalculateX(x, λ)
        let newY = doubleCalculateY(newX, λ)

        let point = NewPoint(x: newX, y: newY)
        return point.modularized()
    }
}
private extension NewPoint {
    func doubleCalculateLambda(_ x: F, _ y: F) -> F { (3 * x * x) * ((2 * y).modInverse()) }
    func doubleCalculateX(_ x: F, _ λ: F) -> F { (λ * λ) - 2 * x }
    func doubleCalculateY(_ newX: F, _ λ: F) -> F { (λ * x - newX) - y }
}

// MARK: - Points Substraction
extension NewPoint {
    static func - (p1: Self, p2: Self) -> NewPoint { p1 + (-p2) }
}
extension NewPoint {
    static prefix func - (p: NewPoint) -> NewPoint { .init(x: p.x, y: -p.y).modularized() }
}

// MARK: - Others
extension NewPoint {
    func isAtInfinity() -> Bool { y == nil }
    func isPointOfG1() -> Bool { F.self == Fq1.self }
    func isPointOfG2() -> Bool { F.self == Fq2.self }
}
