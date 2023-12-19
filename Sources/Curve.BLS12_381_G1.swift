//
//  Curve.BLS12_381_G1.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

extension Curve { struct BLS12_381_G1: CurveSuite {
    let dst: String = "QUUX-V01-CS02-with-BLS12381G1_XMD:SHA-256_SSWU_RO_"
    let A: ComplexValue = [0]
    var Aʹ: ComplexValue = [.init(hex: "144698a3b8e9433d693a02c96d4982b0ea985383ee66a8d8e8981aefd881ac98936f8da0e0f97f5cf428082d584c1d")]
    let B: ComplexValue = [4]
    var Bʹ: ComplexValue = [.init(hex: "12e2908d11688030018b12e8753eee3b2016c1f0f24f4070a0b9c14fcef35ef55a23215a316ceaa5d1cc48e98e172be0")]
    let p: BInt = .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")
    let r: BInt = .init(hex: "73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001")
    let m: Int = 1
    let L: Int = 64
    let Z: BInt = .init(hex: "1A0111EA397FE69A4B1BA7B6434BACD764774B84F38512BF6730D2A0F6B0F6241EABFFFEB153FFFFB9FEFFFFFFFFAAA8")
    let hEff: BInt = .init(hex: "d201000000010001")
    let expandMessage: MessageExpander
}}

// MARK: - Point Serialization
extension Curve.BLS12_381_G1 {
    func serializePoint(_ point: CurvePoint) throws -> [UInt8] {
        switch point.isAtInfinity() {
            case true: return try serializePointAtInfinity()
            case false: return try serializeRegularPoint(point)
        }
    }
}
private extension Curve.BLS12_381_G1 {
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
private extension Curve.BLS12_381_G1 {
    func calculateSerializationYFlag(_ y: BInt) -> UInt8 { y > (-y).mod(r) ? serializationYFlag : 0 }
}
private extension Curve.BLS12_381_G1 {
    var serializationInfinityFlag: UInt8 { 192 }
    var serializationYFlag: UInt8 { 32 }
    var serializationCompressionFlag: UInt8 { 128 }
}

// MARK: - Point Deserialization
extension Curve.BLS12_381_G1 {
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint {
        try precheckPoint(bytes)

        switch isPointAtInfinity(bytes) {
            case true: return try deserializePointAtInfinity(bytes)
            case false: return try deserializeRegularPoint(bytes)
        }
    }
}
private extension Curve.BLS12_381_G1 {
    func deserializePointAtInfinity(_ bytes: [UInt8]) throws -> CurvePoint {
        try checkPointAtInfinity(bytes)
        return .init(x: 0, y: nil, self)
    }
    func deserializeRegularPoint(_ bytes: [UInt8]) throws -> CurvePoint {
        var point = createRegularPoint(bytes)
        try checkRegularPoint(point)

        updateRegularPointYCoordinateIfNeeded(bytes, &point)
        return point.modularized()
    }
}
private extension Curve.BLS12_381_G1 {
    func precheckPoint(_ bytes: [UInt8]) throws {
        if bytes.count != 48 { throw Error.Deserialization.invalidSize }
    }
    func checkPointAtInfinity(_ bytes: [UInt8]) throws {
        if bytes[0] & 63 != 0 { throw Error.Deserialization.invalidPoint }
        for byte in bytes.dropFirst() { if byte != 0 { throw Error.Deserialization.invalidPoint } }
    }
    func checkRegularPoint(_ point: CurvePoint) throws {
        if point.x >= p { throw Error.Deserialization.invalidPoint }
        if point.isAtInfinity() { throw Error.Deserialization.invalidPoint }
    }
}
private extension Curve.BLS12_381_G1 {
    func isPointAtInfinity(_ bytes: [UInt8]) -> Bool { bytes[0] & 64 != 0 }
    func createRegularPoint(_ bytes: [UInt8]) -> CurvePoint { 
        var bytes = bytes
        bytes[0] &= 31
        
        let xCoordinate = Primitives.bytesToInteger(bytes)
        let point = CurvePoint(x: xCoordinate, self)
        return point
    }
    func updateRegularPointYCoordinateIfNeeded(_ bytes: [UInt8], _ point: inout CurvePoint) {
        let yFlag = (bytes[0] & serializationYFlag) > 0
        let yComparisonFlag = point.y > (-point.y).mod(r)

        if yFlag != yComparisonFlag { point.y.negate() }
    }
}

// MARK: - Mapping To Curve
extension Curve.BLS12_381_G1 {
    func mapToCurve(_ u: ComplexValue) -> CurvePoint { MapToCurve(self).svdw(u) }
}

// MARK: - Base Point
extension Curve.BLS12_381_G1 {
    var BPx: ComplexValue { fatalError() }
    var BPy: ComplexValue { fatalError() }
}


// MARK: - Errors
fileprivate typealias Error = BLS12_381_G1Error
enum BLS12_381_G1Error {
    enum Deserialization: Swift.Error { case invalidSize, invalidPoint }
}
