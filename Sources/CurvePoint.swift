//
//  CurvePoint.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

struct CurvePoint {
    let x: BigUInt
    let y: BigUInt
}

// MARK: - Point Addition
extension CurvePoint {
    static func +(lhs: Self, rhs: Self) -> CurvePoint {
        fatalError()
    }
}
