//
//  Fq1.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Fq1: Field {
    let t0: BInt

    let primeField: BInt
}
extension Fq1 {
    static func * (lhs: Fq1, rhs: Fq1) -> Fq1 { .init(
        t0: (lhs.t0 * rhs.t0).mod(lhs.primeField),
        primeField: lhs.primeField
    )}
    static func * (lhs: Fq1, rhs: BInt) -> Fq1 { .init(
        t0: (lhs.t0 * rhs).mod(lhs.primeField),
        primeField: lhs.primeField
    )}
    static func + (lhs: Fq1, rhs: Fq1) -> Fq1 { .init(
        t0: (lhs.t0 + rhs.t0).mod(lhs.primeField),
        primeField: lhs.primeField
    )}
}
extension Fq1 {
    func modInverse() -> Fq1 { .init(
        t0: t0.modInverse(primeField),
        primeField: primeField
    )}
    func mulNonRes() -> Fq1 { self }
}
