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

class MapToCurve {
    let curve: CurveSuite

    init(_ curve: CurveSuite) { self.curve = curve }
}

// MARK: - Shallue-van de Woestijne method
extension MapToCurve {
    func svdw(_ u: ComplexValue) -> CurvePoint {
        // MARK: Pre-calculated
        let c1 = f(Z),
            c2 = u * u * c1,
            c3 = 3 * Z * Z + 4 * A

        // MARK: Temporary Values
        let tv1 = 1 - c2
        let tv2 = 1 + c2
        let tv3 = multiplicativeInverse(tv1 * tv2)
        let tv4 = abs(squareRoot(-c1 * c3))
        let tv5 = u * tv1 * tv3 * tv4
        let tv6 = -4 * c1 * multiplicativeInverse(c3)

        // MARK: Calculating x and y
        let x = svdwCalculateX(tv2, tv3, tv5, tv6)
        let y = svdwCalculateY(x, u)
        return .init(xComplex: x, yComplex: y, curve).modularized()
    }
}
private extension MapToCurve {
    func svdwCalculateX(_ tv2: ComplexValue, _ tv3: ComplexValue, _ tv5: ComplexValue, _ tv6: ComplexValue) -> ComplexValue {
        let x1 = -Z * BInt(2).modInverse(p) - tv5
        if isSquare(f(x1)) { return x1 }

        let x2 = -Z * BInt(2).modInverse(p) + tv5
        if isSquare(f(x2)) { return x2 }

        let x3 = Z + tv6 * (tv2 * tv2 * tv3) * (tv2 * tv2 * tv3)
        return x3
    }
    func svdwCalculateY(_ x: ComplexValue, _ u: ComplexValue) -> ComplexValue {
        let y1 = squareRoot(f(x))
        return isNegative(u) == isNegative(y1) ? y1 : -y1
    }
}

// MARK: - Simplified Shallue-van de Woestijne-Ulas method
extension MapToCurve {
    func swu(_ u: ComplexValue, A: ComplexValue? = nil, B: ComplexValue? = nil) -> CurvePoint { let A = A ?? self.A, B = B ?? self.B
        // MARK: Pre-calculated
        let c1 = u.exp(2, p),
            c2 = (c1 * c1).mod(p)

        // MARK: Temporary Values
        let tv1 = (Z * Z * c2 + Z * c1).modInverse(p)

        // MARK: Calculating x and y
        var (x, y) = swuCalculateCoordinates(c1, tv1, A, B)
        if isNegative(u) != isNegative(y) { y.negate() }
        return .init(xComplex: x, yComplex: y, curve).modularized()
    }
}
private extension MapToCurve {
    func swuCalculateCoordinates(_ c1: ComplexValue, _ tv1: ComplexValue, _ A: ComplexValue, _ B: ComplexValue) -> (x: ComplexValue, y: ComplexValue) {
        let x1 = swuCalculateXCandidate1(tv1, A, B)
        let gx1 = x1.exp(3, p) + A * x1 + B
        if isSquare(gx1) { return (x1, squareRoot(gx1)) }

        let x2 = Z * c1 * x1
        let gx2 = x2.exp(3, p) + A * x2 + B
        return (x2, squareRoot(gx2))
    }
}
private extension MapToCurve {
    func swuCalculateXCandidate1(_ tv1: ComplexValue, _ A: ComplexValue, _ B: ComplexValue) -> ComplexValue { let tv1 = tv1.mod(p)
        switch tv1.real == 0 && tv1.imaginary == 0 {
            case true: return B * (Z * A).modInverse(p)
            case false: return -B * A.modInverse(p) * (1 + tv1)
        }
    }
}

// MARK: - Simplified SWU for AB == 0
extension MapToCurve {
    func sswu(_ u: ComplexValue) -> CurvePoint {
        let curvePointʹ = swu(u, A: Aʹ, B: Bʹ)
        let curvePoint = curve.isoMap(curvePointʹ)

        return curvePoint
    }
}


// MARK: - Common Functions
private extension MapToCurve {
    func abs(_ x: ComplexValue) -> ComplexValue { isNegative(x) ? -x : x }
    func multiplicativeInverse(_ x: ComplexValue) -> ComplexValue { x.modInverse(p) }
    func squareRoot(_ x: ComplexValue) -> ComplexValue { x.sqrtMod(p) }
    func isNegative(_ x: ComplexValue) -> Bool { let x0 = x.real.mod(p), x1 = x.imaginary?.mod(p) ?? 0
        let sign0 = x0.mod(2) == 1
        let zero0 = x0 == 0
        let sign1 = x1.mod(2) == 1
        return sign0 || (zero0 && sign1)
    }
    func isSquare(_ x: ComplexValue) -> Bool { let x0 = x.real, x1 = x.imaginary
        if x1 == nil {
            let a = x.real.expMod((p - 1) / 2, p)
            return a == 0 || a == 1
        }

        // MARK: Pre-calculated
        let c1 = (p - 1) * BInt(2).modInverse(p)

        // MARK: Temporary Values
        let tv1 = x0 * x0
        let tv2 = x1 * x1
        let tv3 = (tv1 + tv2).expMod(c1.mod(p), p)

        let neg1 = BInt(-1).mod(p)
        return tv3 != neg1
    }
}

// MARK: - Curve Helpers
private extension MapToCurve {
    func f(_ x: ComplexValue) -> ComplexValue { curve.f(x) }
}
private extension MapToCurve {
    var p: BInt { curve.p }
    var A: ComplexValue { curve.A }
    var Aʹ: ComplexValue { curve.Aʹ }
    var B: ComplexValue { curve.B }
    var Bʹ: ComplexValue { curve.Bʹ }
    var Z: ComplexValue { curve.Z }
}
