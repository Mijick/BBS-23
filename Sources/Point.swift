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
    static func addEvalHelper(_ wideR: CurvePoint<Fq12>, _ wideQ: CurvePoint<Fq12>, _ p: CurvePoint<Fq1>) -> Fq12 {
        let slope = (wideQ.y - wideR.y) * (wideQ.x - wideR.x).modInverse()

        let p1: Fq12 = [p.y.t0]
        let p2: Fq12 = [p.x.t0] * slope
        let p3 = (wideQ.y * wideR.x) - (wideR.y * wideQ.x) * (wideR.x - wideQ.x).modInverse()

        return p1 - p2 - p3
    }
}


// MARK: - Miller
extension Fq12 {
    static func miller(_ p: CurvePoint<Fq1>, q: CurvePoint<Fq2>) -> Fq12 {
        var value = BInt(hex: "d201000000010000")
        var iterations: [Bool] = []

        while value > 0 {
            iterations.append(value.isOdd)
            value = value >> 1
        }

        iterations = Array(iterations.reversed().dropFirst())

        return millerHelper(p, q, q, iterations, 1)
    }
}
private extension Fq12 {
    static func millerHelper(_ p: CurvePoint<Fq1>, _ q: CurvePoint<Fq2>, _ r: CurvePoint<Fq2>, _ iters: [Bool], _ result: Fq12) -> Fq12 {
        if iters == [] { return result }

        let i = iters.first!
        let iters = Array(iters[1..<iters.count])

        let accum = result * result * doubleEval(p, r)
        let doubleR = r * 2



        if i {
            let newR = doubleR + q
            let newResult = accum * addEval(p, q: q, r: doubleR)
            return millerHelper(p, q, newR, iters, newResult)
        }

        return millerHelper(p, q, doubleR, iters, accum)
    }
}

// MARK: - Pairing
extension Fq12 {
    static func pair(_ pG1: CurvePoint<Fq1>, _ pG2: CurvePoint<Fq2>) throws -> Fq12 {
        if pG1.isAtInfinity() || pG2.isAtInfinity() { fatalError() }


        let p = BBSSettings.ciphersuite.p
        let r = BBSSettings.ciphersuite.r
        // sprawdź jeszcze czy oba punkty leżą na Curve

        let rr = miller(pG1, q: pG2)
        let mm = ((p.expMod(12, p) - 1) / r).mod(p)

        return rr.exp(mm)
    }
}







