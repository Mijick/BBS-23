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
    let x: [UInt8]
    let y: [UInt8]

    init(_ bytes: [UInt8]) {
        self.x = bytes.left
        self.y = bytes.right
    }
}


// MARK: - Helpers
fileprivate extension [UInt8] {
    var left: [UInt8] { .init(self[0 ..< count / 2]) }
    var right: [UInt8] { .init(self[count / 2 ..< count - 1]) }
}
