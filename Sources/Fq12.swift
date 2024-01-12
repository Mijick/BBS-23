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
}
extension Fq12 {
    init(_ v: [BInt]) { self.w0 = .init(v.get(0) ?? 0); self.w1 = .init(v.get(1) ?? 0) }
}

// MARK: - Operations
extension Fq12 {
    static func * (lhs: Fq12, rhs: Fq12) -> Fq12 { .init(
        w0: lhs.w0 * rhs.w0 + (lhs.w1 * rhs.w1).mulNonRes(),
        w1: lhs.w1 * rhs.w0 + lhs.w0 * rhs.w1
    )}
    static func * (lhs: Fq12, rhs: BInt) -> Fq12 { .init(
        w0: lhs.w0 * rhs,
        w1: lhs.w1 * rhs
    )}
    static func + (lhs: Fq12, rhs: Fq12) -> Fq12 { .init(
        w0: lhs.w0 + rhs.w0,
        w1: rhs.w1 + rhs.w1
    )}
}
extension Fq12 {
    func mod() -> Fq12 { .init(w0: w0.mod(), w1: w1.mod()) }
    func modInverse() -> Fq12 {
        let factor = (w0 * w0 - (w1 * w1).mulNonRes()).modInverse()

        return .init(
            w0: w0 * factor,
            w1: -w1 * factor
        )
    }
    func mulNonRes() -> Fq12 { fatalError() }
    func exp(_ x: BInt) -> Fq12 { fatalError() }
    func squareRoot() -> Fq12 { fatalError() }
}
