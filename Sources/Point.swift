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


extension CurvePoint where F == Fq2 {
    func untwist() -> CurvePoint<Fq12> {
        let root = Fq6(v0: 0, v1: 1, v2: 0)

        let ax = Fq12(w0: [[x.u0.t0], [x.u1.t0]], w1: 0)
        let bx = Fq12(w0: root, w1: 0).modInverse()

        let aY = Fq12(w0: [[y.u0.t0, y.u1.t0]], w1: 0)
        let bY = Fq12(w0: 0, w1: root).modInverse()

        return .init(x: ax * bx, y: aY * bY)
    }
}
















// MARK: - Double Eval
extension Fq12 {
    static func doubleEval(_ p: CurvePoint<Fq1>, _ r: CurvePoint<Fq2>) -> Fq12 {
        let wideR = r.untwist()
        let slope = (3 * (wideR.x * wideR.x)) * (2 * wideR.y).modInverse()

        let p1: Fq12 = [p.y.t0]
        let p2: Fq12 = [p.x.t0] * slope
        let p3 = wideR.y - slope * wideR.x

        return p1 - p2 - p3
    }
}


// MARK: - Add Eval
extension Fq12 {
    static func addEval(_ p: CurvePoint<Fq1>, q: CurvePoint<Fq2>, r: CurvePoint<Fq2>) -> Fq12 {
        let wideR = r.untwist()
        let wideQ = q.untwist()

        if wideR.x == wideQ.x && wideR.y == -wideQ.y { return [p.x.t0] - wideR.x }
        return addEvalHelper(wideR, wideQ, p)
    }
}
private extension Fq12 {
    static func addEvalHelper(_ p1: CurvePoint<Fq12>, _ p2: CurvePoint<Fq12>, _ p3: CurvePoint<Fq1>) -> Fq12 {
        fatalError()
    }

}


// MARK: - Miller
extension Fq12 {
    static func miller(_ p: CurvePoint<Fq1>, q: CurvePoint<Fq2>) -> Fq12 {
        fatalError()
    }
}

// MARK: - Pairing
extension Fq12 {
    static func pair(_ pG1: CurvePoint<Fq1>, _ pG2: CurvePoint<Fq2>) -> Fq12 {
        fatalError()
    }
}







