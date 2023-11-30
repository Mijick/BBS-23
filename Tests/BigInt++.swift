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

// MARK: Helpers
extension BigInt {
    func toHashString(radix: Int) -> String {
        let hexData = String(self, radix: radix)
        
        switch sign {
            case .minus: return "1" + hexData
            case .plus: return "0" + hexData
        }
    }
}
