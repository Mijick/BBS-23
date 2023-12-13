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
    func serializePoint(_ point: CurvePoint) throws -> [UInt8] {
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
    func serializeRegularPoint(_ point: CurvePoint) throws -> [UInt8] {
        var result = try Primitives.integerToBytes(value: 0, expectedLength: 96)
        result.replaceSubrange(0..<48, with: try calculateSerializationLeftSide(point))
        result.replaceSubrange(48..<96, with: try calculateSerializationRightSide(point))
        result[0] += serializationCompressionFlag
        result[0] += calculateSerializationYFlag(point.yComplex)
        return result
    }
}
private extension Curve.BLS12_381_G2 {
    func calculateSerializationLeftSide(_ point: CurvePoint) throws -> [UInt8] { try point.xComplex.imaginary!.toBytes(expectedLength: 48) }
    func calculateSerializationRightSide(_ point: CurvePoint) throws -> [UInt8] { try point.xComplex.real.toBytes(expectedLength: 48) }
    func calculateSerializationYFlag(_ y: ComplexValue?) -> UInt8 { y > -y?.mod(r) ? serializationYFlag : 0 }
}
private extension Curve.BLS12_381_G2 {
    var serializationInfinityFlag: UInt8 { 192 }
    var serializationYFlag: UInt8 { 32 }
    var serializationCompressionFlag: UInt8 { 128 }
}

// MARK: - Point Deserialization
extension Curve.BLS12_381_G2 {
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint {
        try precheckPoint(bytes)

        switch isPointAtInfinity(bytes) {
            case true: return try deserializePointAtInfinity(bytes)
            case false: return try deserializeRegularPoint(bytes)
        }
    }
}
private extension Curve.BLS12_381_G2 {
    func deserializePointAtInfinity(_ bytes: [UInt8]) throws -> CurvePoint {
        try checkPointAtInfinity(bytes)
        return .init(xComplex: [0, 0], yComplex: nil, self)
    }
    func deserializeRegularPoint(_ bytes: [UInt8]) throws -> CurvePoint {
        var point = createRegularPoint(bytes)
        try checkRegularPoint(point)

        updateRegularPointYCoordinateIfNeeded(bytes, &point)
        return point
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
    func checkRegularPoint(_ point: CurvePoint) throws {
        if point.xComplex.real >= p || point.xComplex.imaginary! >= p { throw Error.Deserialization.invalidPoint }
        if point.isAtInfinity() { throw Error.Deserialization.invalidPoint }
    }
}
private extension Curve.BLS12_381_G2 {
    func isPointAtInfinity(_ bytes: [UInt8]) -> Bool { bytes[0] & 64 != 0 }
    func createRegularPoint(_ bytes: [UInt8]) -> CurvePoint {
        var bytes = bytes
        bytes[0] &= 31

        let xRealCoordinate = Primitives.bytesToInteger(.init(bytes[48..<96]))
        let xImaginaryCoordinate = Primitives.bytesToInteger(.init(bytes[0..<48]))

        let point = CurvePoint(xComplex: [xRealCoordinate, xImaginaryCoordinate], self)
        return point
    }
    func updateRegularPointYCoordinateIfNeeded(_ bytes: [UInt8], _ point: inout CurvePoint) {
        let yFlag = (bytes[0] & serializationYFlag) > 0
        let yComparisonFlag = point.yComplex > (-point.yComplex).mod(r)

        if yFlag != yComparisonFlag { point.yComplex.negate() }
    }
}

// MARK: - Mapping To Curve
extension Curve.BLS12_381_G2 {
    func mapToCurve(_ u: BInt) -> CurvePoint {
        fatalError()
    }
}

// MARK: - Expanding Message
extension Curve.BLS12_381_G2 {
    func expandMessage(_ messageBytes: [UInt8], domainSeparationTag: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8] {
        fatalError()
    }
}

// MARK: - Base Point
extension Curve.BLS12_381_G2 {
    var BPx: ComplexValue {[
        .init(hex: "024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8"),
        .init(hex: "13e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e")
    ]}
    var BPy: ComplexValue {[
        .init(hex: "0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801"),
        .init(hex: "0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be")
    ]}
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
