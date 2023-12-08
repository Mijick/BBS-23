//
//  Cipher.BLS12_381_SHA_256.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

extension Cipher { struct BLS12_381_SHA_256: CipherSuite {
    let id: String = "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_"
    let octetScalarLength: Int = 32
    let octetPointLength: Int = 48
    let expandLength: Int = 48
    let p1: BInt = .init(hex: "a8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9")
    let curve: CurveSuite = Curve.BLS12_381_G1()
}}


// MARK: - Point Serialization
extension Cipher.BLS12_381_SHA_256 {
    func serializePoint(_ point: CurvePoint) throws -> [UInt8] {
        switch point.isAtInfinity() {
            case true: return try serializePointAtInfinity()
            case false: return try serializeRegularPoint(point)
        }
    }
}
private extension Cipher.BLS12_381_SHA_256 {
    func serializePointAtInfinity() throws -> [UInt8] {
        var result = try Primitives.integerToBytes(value: 0, expectedLength: 48)
        result[0] = serializationInfinityFlag
        return result
    }
    func serializeRegularPoint(_ point: CurvePoint) throws -> [UInt8] {
        var result = try Primitives.integerToBytes(value: point.x, expectedLength: 48)
        result[0] += serializationCompressionFlag
        result[0] += calculateSerializationYFlag(point.y)
        return result
    }
}
private extension Cipher.BLS12_381_SHA_256 {
    func calculateSerializationYFlag(_ y: BInt) -> UInt8 { y > (-y).mod(curve.r) ? 32 : 0 }
}
private extension Cipher.BLS12_381_SHA_256 {
    var serializationInfinityFlag: UInt8 { 192 }
    var serializationYFlag: UInt8 { 32 }
    var serializationCompressionFlag: UInt8 { 128 }
}

// MARK: - Octets to Point
extension Cipher.BLS12_381_SHA_256 {
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint {
        if bytes.count != 48 { fatalError() }

        // Checks infinity flag
        if bytes[0] & 64 != 0 {
            fatalError()
        }


        let yFlag = (bytes[0] & 32) > 0

        var bytes = bytes
        bytes[0] = bytes[0] & 31

        let x = Primitives.bytesToInteger(bytes)
        let point = CurvePoint(x: x, curve: curve)
        return point

        // sprawdzanie jednego


        




    }
}
