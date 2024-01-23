//
//  BilinearPairing.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt


extension CurvePoint<Fq2> {
    func untwist() -> CurvePoint<Fq12> {
        let root = Fq6(v0: 0, v1: 1, v2: 0)
        let wideX = Fq12(w0: .init(v0: x, v1: 0, v2: 0), w1: 0) * Fq12(w0: root, w1: 0).modInverse()
        let wideY = Fq12(w0: .init(v0: y, v1: 0, v2: 0), w1: 0) * Fq12(w0: 0, w1: root).modInverse()

        return .init(x: wideX, y: wideY)
    }
}


extension Fq12: CustomStringConvertible {
    var description: String {
        """
        w1: \(w1)
        w0: \(w0)
        """
    }
}


extension Fq6: CustomStringConvertible {
    var description: String {
        """

            v2: \(v2)
            v1: \(v1)
            v0: \(v0)
        
        """
    }
}

extension Fq2: CustomStringConvertible {
    var description: String {
        """
        
                u1: \(u1)
                u0: \(u0)

        """
    }
}

extension Fq1: CustomStringConvertible {
    var description: String { t0.asString(radix: 10, uppercase: false) }
}






struct BilinearPairing {
    let pG1: CurvePoint<Fq1>
    let pG2: CurvePoint<Fq2>
}

// MARK: - Tate Pairing
extension BilinearPairing {
    func pair() throws -> Fq12 {
        if pG1.isAtInfinity() || pG2.isAtInfinity() { fatalError() }

        // sprawdź jeszcze czy oba punkty leżą na Curve




        let exponential = (fieldPrime.exp(12) - 1) / groupOrder
        return miller().exp(exponential)
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
}



fileprivate extension BInt {
    func exp(_ exponent: Int) -> BInt {
        if exponent == 0 { return 1 }
        if exponent == 1 { return self }
        if exponent < 0 {
            precondition(!self.isZero)
            return self == 1 ? 1 : 0
        }
        if self <= 1 { return self }
        var result = BInt(1)
        var b = self
        var e = exponent
        while e > 0 {
            if e & 1 == 1 {
                result *= b
            }
            e >>= 1
            b *= b
        }
        return result
    }
}
