//
//  Fq2.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Fq2: Field {
    let u0: Fq1
    let u1: Fq1

    let primeField: BInt
}
extension Fq2 {
    static func * (lhs: Fq2, rhs: Fq2) -> Fq2 { .init(
        u0: lhs.u0 * rhs.u0 - lhs.u1 * rhs.u1,
        u1: lhs.u1 * rhs.u0 + lhs.u0 * rhs.u1,
        primeField: lhs.primeField
    )}
    static func * (lhs: Fq2, rhs: BInt) -> Fq2 { .init(
        u0: lhs.u0 * rhs,
        u1: lhs.u1 * rhs,
        primeField: lhs.primeField
    )}
    static func + (lhs: Fq2, rhs: Fq2) -> Fq2 { .init(
        u0: lhs.u0 + rhs.u0,
        u1: lhs.u1 + rhs.u1,
        primeField: lhs.primeField
    )}
}
extension Fq2 {
    func modInverse() -> Fq2 {
        let factor = (u0 * u0 + u1 * u1).modInverse()

        return .init(
            u0: u0 * factor,
            u1: -u1 * factor,
            primeField: primeField
        )
    }
    func mulNonRes() -> Fq2 { .init(
        u0: u0 - u1,
        u1: u0 + u1,
        primeField: primeField
    )}
}
