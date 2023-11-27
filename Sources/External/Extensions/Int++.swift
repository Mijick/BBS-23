//
//  Int++.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

extension Int {
    func toBytes(expectedLength: Int) throws -> [UInt8] { try BInt(self).toBytes(expectedLength: expectedLength) }
}
