//
//  Curve.BLS12_381_G2.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

extension Curve { struct BLS12_381_G2: CurveSuite {
    let dst: String = "QUUX-V01-CS02-with-BLS12381G2_XMD:SHA-256_SSWU_RO_"
    let A: BInt = 0
    let B: ComplexValue = [4, 4]
    let p: BInt = .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")
    let r: BInt = .init(hex: "73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001")
    let m: Int = 2
    let L: Int = 64
    let Z: BInt = .init(hex: "1A0111EA397FE69A4B1BA7B6434BACD764774B84F38512BF6730D2A0F6B0F6241EABFFFEB153FFFFB9FEFFFFFFFFAAA8")
    let hEff: BInt = .init(hex: "bc69f08f2ee75b3584c6a0ea91b352888e2a8e9145ad7689986ff031508ffe1329c2f178731db956d82bf015d1212b02ec0ec69d7477c1ae954cbc06689f6a359894c0adebbf6b4e8020005aaa95551")
}}

// MARK: - Point Serialization
extension Curve.BLS12_381_G2 {
    
}

// MARK: - Point Deserialization
extension Curve.BLS12_381_G2 {
    
}

// MARK: - Mapping To Curve
extension Curve.BLS12_381_G2 {
    
}

// MARK: - Expanding Message
extension Curve.BLS12_381_G2 {
    
}

// MARK: - Hashing
extension Curve.BLS12_381_G2 {
    func hashData(_ bytes: [UInt8]) -> [UInt8] { Hash.sha256(bytes) }
}
extension Curve.BLS12_381_G2 {
    var hashOutputSizeInBytes: Int { 64 }
}


// MARK: - Errors
fileprivate typealias Error = BLS12_381_G2Error
enum BLS12_381_G2Error {
    enum ExpandMessage: Swift.Error { case expectedLengthMustBePositive, expectedLengthTooLarge, domainSeperationTagTooBig, helperArrayTooBig }
    enum Deserialization: Swift.Error { case invalidSize, invalidPoint }
}
