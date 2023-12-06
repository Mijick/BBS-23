//
//  BInt++.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

extension BInt {
    init(decimal value: String) { self.init(value, radix: 10)! }
    init(hex value: String) { self.init(value, radix: 16)! }
}
