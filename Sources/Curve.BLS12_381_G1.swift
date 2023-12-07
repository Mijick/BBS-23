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
    let B: BInt = 4
    let p: BInt = .init(hex: "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab")
    let m: Int = 1
    let L: Int = 64
    let Z: BInt = .init(hex: "1A0111EA397FE69A4B1BA7B6434BACD764774B84F38512BF6730D2A0F6B0F6241EABFFFEB153FFFFB9FEFFFFFFFFAAA8")
    let hEff: BInt = .init(hex: "d201000000010001")
}}

// MARK: - Mapping To Curve
extension Curve.BLS12_381_G1 {
    func mapToCurve(_ u: BInt) -> CurvePoint {
        let c1 = f(Z),
            c2 = 3 * Z * Z + 4 * A,
            c3 = -Z / 2


        var tv1 = u * u * c1
        let tv2 = 1 + tv1
        tv1 = 1 - tv1

        let tv3 = inv0(tv1 * tv2)
        var tv4 = sqrt(-c1 * c2)


        if sgn0(tv4) == 1 { tv4 = (0 - tv4) }

        let tv5 = (u * tv1 * tv3 * tv4)

        let tv6 = -4 * c1 * inv0(c2)

        
        let x = {
            let x1 = c3 - tv5
            if isSquare(f(x1)) { return x1 }

            let x2 = c3 + tv5
            if isSquare(f(x2)) { return x2 }

            let x3 = Z + tv6 * (tv2 * tv2 * tv3) ** 2
            return x3
        }()

        var y = sqrt(f(x))
        if sgn0(u) != sgn0(y) { y.negate() }

        return .init(x: x.mod(p), y: y.mod(p), curve: self)
    }

}
private extension Curve.BLS12_381_G1 {
    func inv0(_ x: BInt) -> BInt { x.modInverse(p) }
    func sgn0(_ x: BInt) -> BInt { x.mod(2) }
    func sqrt(_ x: BInt) -> BInt { x.sqrtMod(p)! }
    func isSquare(_ x: BInt) -> Bool {
        let a =  x.expMod((p - 1) / 2, p)

        if a == 0 || a == 1 { return true }
        return false
    }
}
private extension Curve.BLS12_381_G1 {

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
}
