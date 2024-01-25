//
//  Hash.SHA256.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import CommonCrypto

extension Hash { struct SHA256: HashType {
    let bInBytes: Int = 32
    let sInBytes: Int = 64
}}
extension Hash.SHA256 {
    func hashData(_ bytes: [UInt8]) -> [UInt8] { let data = Data(bytes)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash) }
        return hash
    }
}
