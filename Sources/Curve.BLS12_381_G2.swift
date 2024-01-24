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
    let A: Fq2 = [0, 0]
    let Aʹ: Fq2 = [0, 240]
    let B: Fq2 = [4, 4]
    let Bʹ: Fq2 = [1012, 1012]
    let m: Int = 2
    let L: Int = 64
    let Z: Fq2 = [-2, -1]
    let hEff: BInt = "bc69f08f2ee75b3584c6a0ea91b352888e2a8e9145ad7689986ff031508ffe1329c2f178731db956d82bf015d1212b02ec0ec69d7477c1ae954cbc06689f6a359894c0adebbf6b4e8020005aaa95551"
    let expandMessage: MessageExpander
}}

// MARK: - Point Serialization
extension Curve.BLS12_381_G2 {
    func serializePoint(_ point: CurvePoint<Fq2>) throws -> [UInt8] {
        switch point.isAtInfinity() {
            case true: return try serializePointAtInfinity()
            case false: return try serializeRegularPoint(point)
        }
    }
}
private extension Curve.BLS12_381_G2 {
    func serializePointAtInfinity() throws -> [UInt8] {
        var result = try Primitives.integerToBytes(value: 0, expectedLength: 96)
        result[0] += serializationCompressionFlag
        return result
    }
    func serializeRegularPoint(_ point: CurvePoint<Fq2>) throws -> [UInt8] {
        var result = try Primitives.integerToBytes(value: 0, expectedLength: 96)
        result.replaceSubrange(0..<48, with: try calculateSerializationLeftSide(point))
        result.replaceSubrange(48..<96, with: try calculateSerializationRightSide(point))
        result[0] += serializationCompressionFlag
        result[0] += calculateSerializationYFlag(point.y)
        return result
    }
}
private extension Curve.BLS12_381_G2 {
    func calculateSerializationLeftSide(_ point: CurvePoint<Fq2>) throws -> [UInt8] { try point.x.u1.t0.toBytes(expectedLength: 48) }
    func calculateSerializationRightSide(_ point: CurvePoint<Fq2>) throws -> [UInt8] { try point.x.u0.t0.toBytes(expectedLength: 48) }
    func calculateSerializationYFlag(_ y: Fq2?) -> UInt8 { isNegative(y) ? serializationYFlag : 0 }
}
private extension Curve.BLS12_381_G2 {
    var serializationInfinityFlag: UInt8 { 192 }
    var serializationYFlag: UInt8 { 32 }
    var serializationCompressionFlag: UInt8 { 128 }
}

// MARK: - Point Deserialization
extension Curve.BLS12_381_G2 {
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint<Fq2> {
        try precheckPoint(bytes)

        switch isPointAtInfinity(bytes) {
            case true: return try deserializePointAtInfinity(bytes)
            case false: return try deserializeRegularPoint(bytes)
        }
    }
}
private extension Curve.BLS12_381_G2 {
    func deserializePointAtInfinity(_ bytes: [UInt8]) throws -> CurvePoint<Fq2> {
        try checkPointAtInfinity(bytes)
        return .init(x: 0, y: nil)
    }
    func deserializeRegularPoint(_ bytes: [UInt8]) throws -> CurvePoint<Fq2> {
        var point = createRegularPoint(bytes)
        try checkRegularPoint(point)

        updateRegularPointYCoordinateIfNeeded(bytes, &point)
        return point.modularized()
    }
}
private extension Curve.BLS12_381_G2 {
    func precheckPoint(_ bytes: [UInt8]) throws {
        if bytes.count != 96 { throw Error.Deserialization.invalidSize }
    }
    func checkPointAtInfinity(_ bytes: [UInt8]) throws {
        if bytes[0] & 63 != 0 { throw Error.Deserialization.invalidPoint }
        for byte in bytes.dropFirst() { if byte != 0 { throw Error.Deserialization.invalidPoint } }
    }
    func checkRegularPoint(_ point: CurvePoint<Fq2>) throws {
        if point.x.u0.t0 >= p || point.x.u1.t0 >= p { throw Error.Deserialization.invalidPoint }
        if point.isAtInfinity() { throw Error.Deserialization.invalidPoint }
    }
}
private extension Curve.BLS12_381_G2 {
    func isPointAtInfinity(_ bytes: [UInt8]) -> Bool { bytes[0] & 64 != 0 }
    func createRegularPoint(_ bytes: [UInt8]) -> CurvePoint<Fq2> {
        var bytes = bytes
        bytes[0] &= 31

        let x: Fq2 = [
            Array(bytes[48..<96]).toInteger(),
            Array(bytes[0..<48]).toInteger()
        ]
        let y = f(x).squareRoot()

        return .init(x: x, y: y)
    }
    func updateRegularPointYCoordinateIfNeeded(_ bytes: [UInt8], _ point: inout CurvePoint<Fq2>) {
        let yFlag = (bytes[0] & serializationYFlag) > 0
        let yComparisonFlag = isNegative(point.y)

        if yFlag != yComparisonFlag { point.y = -point.y }
    }
}

// MARK: - Mapping To Curve
extension Curve.BLS12_381_G2 {
    func mapToCurve(_ u: Fq2) -> CurvePoint<Fq2> { MapToCurve(curve: self).sswu(u) }
}

// MARK: - Base Point
extension Curve.BLS12_381_G2 {
    var BPx: Fq2 {[
        "024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8",
        "13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e"
    ]}
    var BPy: Fq2 {[
        "0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801",
        "0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be"
    ]}
}

// MARK: - Isogeny Map Values
extension Curve.BLS12_381_G2 {
    var xNumConstants: [Fq2] {[
        ["5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6", "5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6"],
        ["0", "11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71a"],
        ["11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71e", "8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38d"],
        ["171d6541fa38ccfaed6dea691f5fb614cb14b4e7f4e810aa22d6108f142b85757098e38d0f671c7188e2aaaaaaaa5ed1", "0"]
    ]}
    var xDenConstants: [Fq2] {[
        ["0", "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa63"],
        ["c", "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa9f"]
    ]}
}
extension Curve.BLS12_381_G2 {
    var yNumConstants: [Fq2] {[
        ["1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706", "1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706"],
        ["0", "5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97be"],
        ["11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71c", "8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38f"],
        ["124c9ad43b6cf79bfbf7043de3811ad0761b0f37a1e26286b0e977c69aa274524e79097a56dc4bd9e1b371c71c718b10", "0"]
    ]}
    var yDenConstants: [Fq2] {[
        ["1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb", "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb"],
        ["0", "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa9d3"],
        ["12", "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa99"]
    ]}
}


// MARK: - Errors
fileprivate typealias Error = BLS12_381_G2Error
enum BLS12_381_G2Error {
    enum Deserialization: Swift.Error { case invalidSize, invalidPoint }
}
