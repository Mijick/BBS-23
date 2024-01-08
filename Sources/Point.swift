//
//  Point.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2024 Mijick. Licensed under MIT License.


import BigInt

struct Point<F: Field> {
    let x: F
    let y: F
    let curve: CurveSuite
}


extension Point where F == Fq2 {
    func untwist() -> Point<Fq12> {
        let root = createFq6([0], [1], [0])

        // MARK: New X
        let ax = createFq12(
            createFq6([x.u0.t0, x.u1.t0]),
            createFq6([0])
        )
        let bx = createFq12(
            root,
            createFq6([0])
        ).modInverse()

        // MARK: New Y
        let aY = createFq12(
            createFq6([y.u0.t0, y.u1.t0]),
            createFq6([0])
        )
        let bY = createFq12(
            createFq6([0]),
            root
        ).modInverse()

        // MARK: Untwisted point
        return .init(x: ax * bx, y: aY * bY, curve: curve)
    }
}



private extension Point {
    func createFq1(_ t0: BInt) -> Fq1 { .init(
        t0: t0,
        primeField: curve.p
    )}
    func createFq2(_ values: [BInt]) -> Fq2 { .init(
        u0: createFq1(values.get(0) ?? 0),
        u1: createFq1(values.get(1) ?? 0),
        primeField: curve.p
    )}
    func createFq6(_ values: [BInt]...) -> Fq6 { .init(
        v0: createFq2(values.get(0) ?? []),
        v1: createFq2(values.get(1) ?? []),
        v2: createFq2(values.get(2) ?? []),
        primeField: curve.p
    )}
    func createFq12(_ w0: Fq6, _ w1: Fq6) -> Fq12 { .init(
        w0: w0,
        w1: w1,
        primeField: curve.p
    )}
}

