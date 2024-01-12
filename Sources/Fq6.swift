//
//  Fq6.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Fq6: Field {
    let v0: Fq2
    let v1: Fq2
    let v2: Fq2
}
extension Fq6 {
    init(_ values: [BInt]...) { self.v0 = .init(values.get(0) ?? []); self.v1 = .init(values.get(1) ?? []); self.v2 = .init(values.get(2) ?? []) }
    init(_ values: BInt...) { self.v0 = .init(values.get(0) ?? 0); self.v1 = .init(values.get(1) ?? 0); self.v2 = .init(values.get(2) ?? 0); }
    init(integerLiteral value: IntegerLiteralType) { self.v0 = .init(integerLiteral: value); self.v1 = .init(0); self.v2 = .init(0) }
}

// MARK: - Operations
extension Fq6 {
    static func * (lhs: Fq6, rhs: Fq6) -> Fq6 {
        let t0 = lhs.v0 * rhs.v0
        let t1 = lhs.v0 * rhs.v1 + lhs.v1 * rhs.v0
        let t2 = lhs.v0 * rhs.v2 + lhs.v1 * rhs.v1 + lhs.v2 * rhs.v0
        let t3 = (lhs.v1 * rhs.v2 + lhs.v2 * rhs.v1).mulNonRes()
        let t4 = (lhs.v2 * rhs.v2).mulNonRes()

        return .init(
            v0: t0 + t3,
            v1: t1 + t4,
            v2: t2
        )
    }
    static func * (lhs: Fq6, rhs: BInt) -> Fq6 { .init(
        v0: lhs.v0 * rhs,
        v1: lhs.v1 * rhs,
        v2: lhs.v2 * rhs
    )}
    static func + (lhs: Fq6, rhs: Fq6) -> Fq6 { .init(
        v0: lhs.v0 + rhs.v0,
        v1: lhs.v1 + rhs.v1,
        v2: lhs.v2 + rhs.v2
    )}
}
extension Fq6 {
    func mod() -> Fq6 { .init(v0: v0.mod(), v1: v1.mod(), v2: v2.mod()) }
    func modInverse() -> Fq6 {
        let t0 = v0 * v0 - (v1 * v2).mulNonRes()
        let t1 = (v2 * v2).mulNonRes() - v0 * v1
        let t2 = v1 * v1 - v0 * v2
        let factor = (v0 * t0 + (v2 * t1).mulNonRes() + (v1 * t2).mulNonRes()).modInverse()

        return .init(
            v0: t0 * factor,
            v1: t1 * factor,
            v2: t2 * factor
        )
    }
    func mulNonRes() -> Fq6 { .init(
        v0: v2.mulNonRes(),
        v1: v0,
        v2: v1
    )}
    func exp(_ x: BInt) -> Fq6 { fatalError() }
    func squareRoot() -> Fq6 { fatalError() }
}
