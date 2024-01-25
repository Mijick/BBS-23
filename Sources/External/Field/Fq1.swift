//
//  Fq1.swift of MijickBBS23
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
}
extension Fq1: ExpressibleByStringLiteral {
    init(_ v: [BInt]) { self.t0 = v.first ?? 0 }
    init(arrayLiteral elements: BInt...) { self.t0 = elements.first ?? 0 }
    init(stringLiteral value: StringLiteralType) { self.t0 = .init(hex: value) }
}

// MARK: - Operations
extension Fq1 {
    static func * (lhs: Fq1, rhs: Fq1) -> Fq1 { .init(
        t0: (lhs.t0 * rhs.t0).mod(lhs.p)
    )}
    static func * (lhs: Fq1, rhs: BInt) -> Fq1 { .init(
        t0: (lhs.t0 * rhs).mod(lhs.p)
    )}
    static func + (lhs: Fq1, rhs: Fq1) -> Fq1 { .init(
        t0: (lhs.t0 + rhs.t0).mod(lhs.p)
    )}
}
extension Fq1 {
    func mod() -> Fq1 { .init(t0: t0.mod(p)) }
    func modInverse() -> Fq1 { .init(t0: t0.modInverse(p))}
    func mulNonRes() -> Fq1 { self }
    func exp(_ x: BInt) -> Fq1 { .init(t0: t0.expMod(x, p)) }
    func squareRoot() -> Fq1 { .init(t0: t0.sqrtMod(p)!) }
}

// MARK: - Printing
extension Fq1 {
    var description: String { t0.asString(radix: 10, uppercase: false) }
}
