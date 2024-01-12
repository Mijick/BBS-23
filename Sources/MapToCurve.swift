//
//  MapToCurve.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

struct MapToCurve<F: Field> {
    let curve: any CurveSuite<F>
}

// MARK: - Shallue-van de Woestijne method
extension MapToCurve {
    func svdw(_ u: ComplexValue) -> CurvePoint { let u = F(u)
        // MARK: Pre-calculated
        let c1 = f(Z),
            c2 = u * u * c1,
            c3 = 3 * Z * Z + 4 * A

        // MARK: Temporary Values
        let tv1 = 1 - c2
        let tv2 = 1 + c2
        let tv3 = (tv1 * tv2).modInverse()
        let tv4 = abs((-c1 * c3).squareRoot())
        let tv5 = u * tv1 * tv3 * tv4
        let tv6 = -4 * c1 * c3.modInverse()

        // MARK: Calculating x and y
        let x = svdwCalculateX(tv2, tv3, tv5, tv6)
        let y = svdwCalculateY(x, u)
        return .init(xComplex: .init(x), yComplex: .init(y), curve).modularized()
    }
}
private extension MapToCurve {
    func svdwCalculateX(_ tv2: F, _ tv3: F, _ tv5: F, _ tv6: F) -> F {
        let x1 = -Z * BInt(2).modInverse(p) - tv5
        if isSquare(f(x1)) { return x1 }

        let x2 = -Z * BInt(2).modInverse(p) + tv5
        if isSquare(f(x2)) { return x2 }

        let x3 = Z + tv6 * (tv2 * tv2 * tv3) * (tv2 * tv2 * tv3)
        return x3
    }
    func svdwCalculateY(_ x: F, _ u: F) -> F {
        let y1 = f(x).squareRoot()
        return isNegative(u) == isNegative(y1) ? y1 : -y1
    }
}

// MARK: - Simplified Shallue-van de Woestijne-Ulas method
extension MapToCurve {
    func swu(_ u: F, A: F? = nil, B: F? = nil) -> CurvePoint { let A = A ?? self.A, B = B ?? self.B
        let c1 = u.exp(2),
            c2 = (c1 * c1).mod()

        let tv1 = (Z * Z * c2 + Z * c1).modInverse()

        var (x, y) = swuCalculateCoordinates(c1, tv1, A, B)
        if isNegative(u) != isNegative(y) { y = -y }
        return .init(xComplex: .init(x), yComplex: .init(y), curve).modularized()
    }
}
private extension MapToCurve {
    func swuCalculateCoordinates(_ c1: F, _ tv1: F, _ A: F, _ B: F) -> (x: F, y: F) {
        let x1 = swuCalculateXCandidate1(tv1, A, B)
        let gx1 = x1.exp(3) + A * x1 + B
        if isSquare(gx1) { return (x1, gx1.squareRoot()) }

        let x2 = Z * c1 * x1
        let gx2 = x2.exp(3) + A * x2 + B
        return (x2, gx2.squareRoot())
    }
}
private extension MapToCurve {
    func swuCalculateXCandidate1(_ tv1: F, _ A: F, _ B: F) -> F { let tv1 = tv1.mod()
        switch tv1 == 0 {
            case true: return B * (Z * A).modInverse()
            case false: return -B * A.modInverse() * (1 + tv1)
        }
    }
}

// MARK: - Simplified SWU for AB == 0
extension MapToCurve {
    func sswu(_ u: ComplexValue) -> CurvePoint { let u = F(u)
        let curvePointʹ = swu(u, A: Aʹ, B: Bʹ)
        let curvePoint = curve.isoMap(curvePointʹ)

        return curvePoint
    }
}


// MARK: - Common Functions
private extension MapToCurve {
    func abs(_ x: F) -> F { isNegative(x) ? -x : x }
    func isNegative(_ x: F) -> Bool {
        if let x = x as? Fq1 { return x.t0.mod(2) == 1 }
        if let x = x as? Fq2 { let x0 = x.u0.t0, x1 = x.u1.t0
            let sign0 = x0.mod(2) == 1
            let zero0 = x0 == 0
            let sign1 = x1.mod(2) == 1
            return sign0 || (zero0 && sign1)
        }
        fatalError()
    }
    func isSquare(_ x: F) -> Bool {
        if let x = x as? Fq1 {
            let a = x.exp((p - 1) / 2)
            return a == 0 || a == 1
        }
        if let x = x as? Fq2 { let x0 = x.u0.t0, x1 = x.u1.t0
            let c1 = ((p - 1) * BInt(2).modInverse(p)).mod(p)

            let tv1 = x0 * x0
            let tv2 = x1 * x1
            let tv3 = (tv1 + tv2).expMod(c1, p)

            let neg1 = BInt(-1).mod(p)
            return tv3 != neg1
        }
        fatalError()
    }
}

// MARK: - Curve Helpers
private extension MapToCurve {
    func f(_ x: F) -> F { curve.f(x) }
}
private extension MapToCurve {
    var p: BInt { BBSSettings.ciphersuite.p }
    var A: F { curve.A }
    var Aʹ: F { curve.Aʹ }
    var B: F { curve.B }
    var Bʹ: F { curve.Bʹ }
    var Z: F { curve.Z }
}








extension Field {
    init(_ complexValue: ComplexValue) {
        if Self.self == Fq1.self { self = Fq1(complexValue.real) as! Self }
        else { self = Fq2(u0: .init(complexValue.real), u1: .init(complexValue.imaginary!)) as! Self }
    }
}


extension ComplexValue {
    init<F: Field>(_ f: F) {
        if let f = f as? Fq1 { self = .init(f.t0) }
        else if let f = f as? Fq2 { self = .init(real: f.u0.t0, imaginary: f.u1.t0) }
        else { fatalError() }
    }
}
