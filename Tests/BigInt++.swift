//
//  BigInt++.swift of BBS-Signature
//
//  Created by Alina Petrovska on 30.11.2023.
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/Mijick
//
//  Copyright ©2023 Mijick. Licensed under MIT License.

import Foundation
import BigInt
@testable import MijickBBS_Signature

// MARK: Helpers
extension BigInt {
    func toHexString() -> String { BigUInt(self).serialize().bytes.toHexRepresentation() }
}
