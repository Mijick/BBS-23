//
//  Int++.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

extension Int {
    func toBytes(expectedLength: Int) throws -> [UInt8] { try Primitives.integerToBytes(value: .init(self), expectedLength: expectedLength) }
}
