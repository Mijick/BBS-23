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
}
extension Fq2 {
    init(_ values: BInt...) { self.u0 = .init(values.get(0) ?? 0); self.u1 = .init(values.get(1) ?? 0) }
    init(_ values: [BInt]) { self.u0 = .init(values.get(0) ?? 0); self.u1 = .init(values.get(1) ?? 0) }
    static var zero: Fq2 { .init(0) }
}

// MARK: - Operations
extension Fq2 {
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
extension Fq2 {
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
    func exp(_ x: BInt) -> Fq2 { let bits = Array(x.asString(radix: 2).reversed())
        var c: Fq2 = .init(u0: .init(1), u1: .zero)

        for i in 0..<381 {
            c = c * c
            if bits.count > 380 - i && bits[380 - i] == "1" { c = (c * self) }
        }

        return c
    }
}
