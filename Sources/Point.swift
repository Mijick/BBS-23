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
    let curve: any CurveSuite
}


extension Point where F == Fq2 {
    func untwist() -> Point<Fq12> {
        let root = Fq6(v0: 0, v1: 1, v2: 0)

        let ax = Fq12(w0: [[x.u0.t0], [x.u1.t0]], w1: 0)
        let bx = Fq12(w0: root, w1: 0).modInverse()

        let aY = Fq12(w0: [[y.u0.t0, y.u1.t0]], w1: 0)
        let bY = Fq12(w0: 0, w1: root).modInverse()

        return .init(x: ax * bx, y: aY * bY, curve: curve)
    }
}
















// MARK: - Double Eval
extension Fq12 {
    static func doubleEval(_ p: Point<Fq1>, _ r: Point<Fq2>) -> Fq12 {
        let wideR = r.untwist()
        let slope = (3 * (wideR.x * wideR.x)) * (2 * wideR.y).modInverse()
        let v = wideR.y - slope * wideR.x



//        let p1 = Fq12(
//            .init([[p.y.t0]]),
//            .init([[0]]),
//            p.primeField
//        )
//        let p2 = createFq12(
//            createFq6([p.x.t0]),
//            createFq6([0])
//        ) * slope



        fatalError()
    }
}


// MARK: - Add Eval
extension Fq12 {
    static func addEval(_ p: Point<Fq1>, q: Point<Fq2>, r: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}
private extension Fq12 {

}


// MARK: - Miller
extension Fq12 {
    static func miller(_ p: Point<Fq1>, q: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}

// MARK: - Pairing
extension Fq12 {
    static func pairing(_ pG1: Point<Fq1>, pG2: Point<Fq2>) -> Fq12 {
        fatalError()
    }
}



extension Fq12 {
    static func pair(pG1: CurvePoint<Fq1>, pG2: CurvePoint<Fq2>) -> Fq12 {
        fatalError()
    }
}







