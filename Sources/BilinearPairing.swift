//
//  BilinearPairing.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct BilinearPairing {
    let pG1: CurvePoint<Fq1>
    let pG2: CurvePoint<Fq2>
}

// MARK: - Tate Pairing
extension BilinearPairing {
    func pair() throws -> Fq12 {
        try pairCheckPoints()

        let exponential = (fieldPrime.exp(12) - 1) / groupOrder
        return miller().exp(exponential)
    }
}
private extension BilinearPairing {
    func pairCheckPoints() throws {
        if pG1.isAtInfinity() || pG2.isAtInfinity() { throw Error.pointsAreAtInfinity }
        if !pG1.isOnCurve(fG1) || !pG2.isOnCurve(fG2) { throw Error.pointsAreNotOnSelectedCurve }
    }
}

// MARK: - Miller
private extension BilinearPairing {
    func miller() -> Fq12 {
        let iterators = millerCreateIterators()
        return millerHelper(pG1, pG2, pG2, iterators, 1)
    }
}
private extension BilinearPairing {
    func millerCreateIterators() -> [Bool] { .init(
        sequence(first: BInt(hex: "d201000000010000")) { let v = $0 >> 1; return v > 0 ? v : nil }
            .map(\.isOdd)
            .reversed()
            .dropFirst()
    )}
    func millerHelper(_ p: CurvePoint<Fq1>, _ q: CurvePoint<Fq2>, _ r: CurvePoint<Fq2>, _ iters: [Bool], _ result: Fq12) -> Fq12 {
        if iters == [] { return result }
        
        let (i, iters) = (iters[0], Array(iters[1..<iters.count]))
        let doubleR = r * 2
        let accum = result * result * doubleEval(p, r)

        let newR = { i ? doubleR + q: doubleR }()
        let newAccum = { i ? accum * addEval(p, q, doubleR) : accum }()
        return millerHelper(p, q, newR, iters, newAccum)
    }
}

// MARK: - Double Eval
private extension BilinearPairing {
    func doubleEval(_ p: CurvePoint<Fq1>, _ r: CurvePoint<Fq2>) -> Fq12 {
        let wideR = r.untwist()
        let slope = (3 * wideR.x * wideR.x) * (2 * wideR.y).modInverse()

        let p1: Fq12 = [p.y.t0]
        let p2: Fq12 = [p.x.t0] * slope
        let p3 = wideR.y - slope * wideR.x
        return p1 - p2 - p3
    }
}

// MARK: - Add Eval
private extension BilinearPairing {
    func addEval(_ p: CurvePoint<Fq1>, _ q: CurvePoint<Fq2>, _ r: CurvePoint<Fq2>) -> Fq12 {
        let wideR = r.untwist(), wideQ = q.untwist()
        return wideR.x == wideQ.x && wideR.y == -wideQ.y ? [p.x.t0] - wideR.x : addEvalHelper(wideR, wideQ, p)
    }
}
private extension BilinearPairing {
    func addEvalHelper(_ wideR: CurvePoint<Fq12>, _ wideQ: CurvePoint<Fq12>, _ p: CurvePoint<Fq1>) -> Fq12 {
        let slope = (wideQ.y - wideR.y) * (wideQ.x - wideR.x).modInverse()

        let p1: Fq12 = [p.y.t0]
        let p2: Fq12 = [p.x.t0] * slope
        let p3 = (wideQ.y * wideR.x - wideR.y * wideQ.x) * (wideR.x - wideQ.x).modInverse()
        return p1 - p2 - p3
    }
}

// MARK: - Helpers
private extension BilinearPairing {
    var fieldPrime: BInt { BBSSettings.ciphersuite.p }
    var groupOrder: BInt { BBSSettings.ciphersuite.r }
    var fG1: (Fq1) -> Fq1 { BBSSettings.ciphersuite.curveG1.f }
    var fG2: (Fq2) -> Fq2 { BBSSettings.ciphersuite.curveG2.f }
}

// MARK: - Errors
extension BilinearPairing {
    enum Error: Swift.Error { case pointsAreAtInfinity, pointsAreNotOnSelectedCurve }
}


// MARK: - External Helpers
fileprivate extension CurvePoint<Fq2> {
    func untwist() -> CurvePoint<Fq12> {
        let root = Fq6(v0: 0, v1: 1, v2: 0)
        let wideX = Fq12(w0: .init(v0: x, v1: 0, v2: 0), w1: 0) * Fq12(w0: root, w1: 0).modInverse()
        let wideY = Fq12(w0: .init(v0: y, v1: 0, v2: 0), w1: 0) * Fq12(w0: 0, w1: root).modInverse()

        return .init(x: wideX, y: wideY)
    }
}
fileprivate extension BInt {
    func exp(_ exponent: Int) -> BInt {
        if exponent < 0 { return 0 }
        if exponent == 0 { return 1 }
        if exponent == 1 { return self }

        if self <= 1 { return self }

        var result = BInt(1), b = self, e = exponent
        while e > 0 {
            if e & 1 == 1 { result *= b }
            e >>= 1
            b *= b
        }
        return result
    }
}
