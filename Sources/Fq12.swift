//
//  Fq12.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Fq12: Field {
    let w0: Fq6
    let w1: Fq6
    
    let primeField: BInt
}
extension Fq12 {
    static func * (lhs: Fq12, rhs: Fq12) -> Fq12 { .init(
        w0: lhs.w0 * rhs.w0 + (lhs.w1 * rhs.w1).mulNonRes(),
        w1: lhs.w1 * rhs.w0 + lhs.w0 * rhs.w1,
        primeField: lhs.primeField
    )}
    static func * (lhs: Fq12, rhs: BInt) -> Fq12 { .init(
        w0: lhs.w0 * rhs,
        w1: lhs.w1 * rhs,
        primeField: lhs.primeField
    )}
    static func + (lhs: Fq12, rhs: Fq12) -> Fq12 { .init(
        w0: lhs.w0 + rhs.w0,
        w1: rhs.w1 + rhs.w1,
        primeField: lhs.primeField
    )}
}
extension Fq12 {
    func modInverse() -> Fq12 {
        let factor = (w0 * w0 - (w1 * w1).mulNonRes()).modInverse()

        return .init(
            w0: w0 * factor,
            w1: -w1 * factor, 
            primeField: primeField
        )
    }
    func mulNonRes() -> Fq12 { fatalError() }
}
