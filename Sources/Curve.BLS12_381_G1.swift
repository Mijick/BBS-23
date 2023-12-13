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
    let A: BInt = 0
    let B: ComplexValue = [4]
    let p: BInt = .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")
    let r: BInt = .init(hex: "73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001")
    let m: Int = 1
    let L: Int = 64
    let Z: BInt = .init(hex: "1A0111EA397FE69A4B1BA7B6434BACD764774B84F38512BF6730D2A0F6B0F6241EABFFFEB153FFFFB9FEFFFFFFFFAAA8")
    let hEff: BInt = .init(hex: "d201000000010001")
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
        return point
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
    func mapToCurve(_ u: ComplexValue) -> CurvePoint { let u = u.real
        // MARK: Pre-calculated
        let c1 = f([Z]).real,
            c2 = u * u * c1,
            c3 = 3 * Z * Z + 4 * A

        // MARK: Temporary Values
        let tv1 = 1 - c2
        let tv2 = 1 + c2
        let tv3 = multiplicativeInverse(tv1 * tv2)
        let tv4 = abs(squareRoot(-c1 * c3))
        let tv5 = u * tv1 * tv3 * tv4
        let tv6 = -4 * c1 * multiplicativeInverse(c3)

        // MARK: Calculating x and y
        let x = calculateX(tv2, tv3, tv5, tv6)
        let y = calculateY(x, u)
        return .init(x: x.mod(p), y: y.mod(p), self)
    }
}
private extension Curve.BLS12_381_G1 {
    func calculateX(_ tv2: BInt, _ tv3: BInt, _ tv5: BInt, _ tv6: BInt) -> BInt {
        let x1 = -Z / 2 - tv5
        if isSquare(f([x1]).real) { return x1 }

        let x2 = -Z / 2 + tv5
        if isSquare(f([x2]).real) { return x2 }

        let x3 = Z + tv6 * (tv2 * tv2 * tv3) ** 2
        return x3
    }
    func calculateY(_ x: BInt, _ u: BInt) -> BInt {
        let y1 = squareRoot(f([x]).real)
        return isNegative(u) == isNegative(y1) ? y1 : -y1
    }
}
private extension Curve.BLS12_381_G1 {
    func abs(_ x: BInt) -> BInt { isNegative(x) ? -x : x }
    func multiplicativeInverse(_ x: BInt) -> BInt { x.modInverse(p) }
    func squareRoot(_ x: BInt) -> BInt { x.sqrtMod(p)! }
    func isNegative(_ x: BInt) -> Bool { x.mod(2) == 1 }
    func isSquare(_ x: BInt) -> Bool {
        let a =  x.expMod((p - 1) / 2, p)
        return a == 0 || a == 1
    }
}

// MARK: - Expanding Message
extension Curve.BLS12_381_G1 {
    func expandMessage(_ messageBytes: [UInt8], domainSeparationTag: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8] {
        let helperBytesArraySize = calculateHelperBytesArraySize(expectedLengthInBytes)

        try assertExpandMessageRequirements(expectedLengthInBytes, domainSeparationTag, helperBytesArraySize)

        let dstPrime = try calculateDomainSeparationTagPrime(domainSeparationTag)
        let zPad = try Primitives.integerToBytes(value: 0, expectedLength: hashOutputSizeInBytes)
        let expectedLengthBytes = try Primitives.integerToBytes(value: .init(expectedLengthInBytes), expectedLength: 2)
        let messagePrime = try calculateMessageBytesPrime(messageBytes, dstPrime, zPad, expectedLengthBytes)
        let hashedMessagePrime = hashData(messagePrime)

        var helperBytesArray = try createHelperBytesArray(hashedMessagePrime, dstPrime)
        try populateHelperBytesArray(&helperBytesArray, helperBytesArraySize, hashedMessagePrime, dstPrime)

        let uniformBytes = helperBytesArray.reduce([]) { $0.concatenate(with: $1) }
        return .init(uniformBytes[0...expectedLengthInBytes - 1])
    }
}
private extension Curve.BLS12_381_G1 {
    func calculateHelperBytesArraySize(_ expectedLengthInBytes: Int) -> Int {
        let expectedLengthInBytes = Double(expectedLengthInBytes), hashOutputSizeInBytes = Double(hashOutputSizeInBytes)

        let result = expectedLengthInBytes / hashOutputSizeInBytes
        return .init(ceil(result))
    }
    func assertExpandMessageRequirements(_ expectedLengthInBytes: Int, _ domainSeparationTag: [UInt8], _ helperBytesArraySize: Int) throws {
        if expectedLengthInBytes <= 0 { throw Error.ExpandMessage.expectedLengthMustBePositive }
        if expectedLengthInBytes > 65535 { throw Error.ExpandMessage.expectedLengthTooLarge }
        if domainSeparationTag.count > 255 { throw Error.ExpandMessage.domainSeperationTagTooBig }
        if helperBytesArraySize > 255 { throw Error.ExpandMessage.helperArrayTooBig }
    }
    func calculateDomainSeparationTagPrime(_ domainSeparationTag: [UInt8]) throws -> [UInt8] {
        let bytes = try Primitives.integerToBytes(value: .init(domainSeparationTag.count), expectedLength: 1)
        return domainSeparationTag.concatenate(with: bytes)
    }
    func calculateMessageBytesPrime(_ messageBytes: [UInt8], _ dstPrime: [UInt8], _ zPad: [UInt8], _ expectedLengthBytes: [UInt8]) throws -> [UInt8] {
        let bytes = try Primitives.integerToBytes(value: 0, expectedLength: 1)
        return zPad
            .concatenate(with: messageBytes)
            .concatenate(with: expectedLengthBytes)
            .concatenate(with: bytes)
            .concatenate(with: dstPrime)
    }
    func createHelperBytesArray(_ hashedMessagePrime: [UInt8], _ dstPrime: [UInt8]) throws -> [[UInt8]] {
        let byte = try Primitives.integerToBytes(value: 1, expectedLength: 1)
        let firstByte = hashedMessagePrime
            .concatenate(with: byte)
            .concatenate(with: dstPrime)

        let hashedFirstByte = hashData(firstByte)
        return [hashedFirstByte]
    }
    func populateHelperBytesArray(_ helperBytesArray: inout [[UInt8]], _ expectedSize: Int, _ hashedMessagePrime: [UInt8], _ dstPrime: [UInt8]) throws { for index in 0...expectedSize {
        let indexBytes = try Primitives.integerToBytes(value: .init(index + 2), expectedLength: 1)
        let xorResult = hashedMessagePrime.xor(helperBytesArray[index])
        let byte = xorResult
            .concatenate(with: indexBytes)
            .concatenate(with: dstPrime)

        let hashedByte = hashData(byte)
        helperBytesArray.append(hashedByte)
    }}
}

// MARK: - Base Point
extension Curve.BLS12_381_G1 {
    var BPx: ComplexValue { fatalError() }
    var BPy: ComplexValue { fatalError() }
}

// MARK: - Hashing
extension Curve.BLS12_381_G1 {
    func hashData(_ bytes: [UInt8]) -> [UInt8] { Hash.sha256(bytes) }
}
extension Curve.BLS12_381_G1 {
    var hashOutputSizeInBytes: Int { 64 }
}


// MARK: - Errors
fileprivate typealias Error = BLS12_381_G1Error
enum BLS12_381_G1Error {
    enum ExpandMessage: Swift.Error { case expectedLengthMustBePositive, expectedLengthTooLarge, domainSeperationTagTooBig, helperArrayTooBig }
    enum Deserialization: Swift.Error { case invalidSize, invalidPoint }
}
