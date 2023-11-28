//
//  Ciphersuite.BLS12_381_SHA_256.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

struct BLS12_381_SHA_256: Ciphersuite {
    let id: String = "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_"
    let octetScalarLength: Int = 32
    let octetPointLength: Int = 48
    let expandLength: Int = 48
    let p1: Int
}

extension BLS12_381_SHA_256 {
    func expandMessage(message: [UInt8], dst: [UInt8], lengthInBytes: Int) -> [UInt8] {
        fatalError()
    }
    func pointToOctets_g1() {
        fatalError()
    }
    func pointToOctets_g2() {
        fatalError()
    }
    func octetsToPoint_g1() {
        fatalError()
    }
    func octetsToPoint_g2() {
        fatalError()
    }
}

extension BLS12_381_SHA_256 {
    func hashData(_ data: Data) -> Data { Primitives.sha256(data) }
}
