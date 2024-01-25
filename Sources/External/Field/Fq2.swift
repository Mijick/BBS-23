//
//  Fq2.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

public struct Fq2: Field {
    let u0: Fq1
    let u1: Fq1
}
public extension Fq2 {
    init(_ v: [BInt]) { self.u0 = .init(t0: v.get(0) ?? 0); self.u1 = .init(t0: v.get(1) ?? 0) }
    init(arrayLiteral elements: BInt...) { self.init(Array(elements)) }
}

// MARK: - Operations
public extension Fq2 {
    static func * (lhs: Fq2, rhs: Fq2) -> Fq2 { .init(
        u0: lhs.u0 * rhs.u0 - lhs.u1 * rhs.u1,
        u1: lhs.u1 * rhs.u0 + lhs.u0 * rhs.u1
    )}
    static func * (lhs: Fq2, rhs: BInt) -> Fq2 { .init(
        u0: lhs.u0 * rhs,
        u1: lhs.u1 * rhs
    )}
    static func + (lhs: Fq2, rhs: Fq2) -> Fq2 { .init(
        u0: lhs.u0 + rhs.u0,
        u1: lhs.u1 + rhs.u1
    )}
}
public extension Fq2 {
    func mod() -> Fq2 { .init(u0: u0.mod(), u1: u1.mod()) }
    func modInverse() -> Fq2 {
        let factor = (u0 * u0 + u1 * u1).modInverse()

        return .init(
            u0: u0 * factor,
            u1: -u1 * factor
        )
    }
    func mulNonRes() -> Fq2 { .init(
        u0: u0 - u1,
        u1: u0 + u1
    )}
    func exp(_ x: BInt) -> Fq2 { let bits = Array(x.mod(p).asString(radix: 2).reversed())
        var c: Fq2 = [1, 0]

        for i in 0..<381 {
            c = c * c
            if bits.count > 380 - i && bits[380 - i] == "1" { c = c * self }
        }

        return c
    }
    func squareRoot() -> Fq2 {
        let c1 = (p - 3) * BInt(4).modInverse(p),
            c2 = (p - 1) * BInt(2).modInverse(p)

        let tv1 = exp(c1)
        let tv2 = tv1 * tv1 * self
        let tv3 = ([1, 0] + tv2).exp(c2)
        let tv4 = tv1 * self

        let neg = Fq2(u0: -1, u1: 0).mod()

        switch tv2 == neg {
            case true: return [0, 1] * tv4
            case false: return tv3 * tv4
        }
    }
}

// MARK: - Printing
public extension Fq2 {
    var description: String {
        """

                u1: \(u1)
                u0: \(u0)

        """
    }
}
