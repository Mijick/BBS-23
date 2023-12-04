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
import BigInt

struct BLS12_381_SHA_256: Ciphersuite {
    let id: String = "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_"
    let octetScalarLength: Int = 32
    let octetPointLength: Int = 48
    let expandLength: Int = 48
    let p1: [UInt8] = "a8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9".asHexToByteRepresentation()
    let primeOrder: [UInt8] = "73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001".asHexToByteRepresentation()


    let p: BigUInt = Primitives.bytesToInteger("0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab".asHexToByteRepresentation())
    let m: Int = 1
    let L: Int = 64
}

// MARK: - Expanding Message
extension BLS12_381_SHA_256 {
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
private extension BLS12_381_SHA_256 {
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

// MARK: - Hashing to Curve
extension BLS12_381_SHA_256 {
    func hashToCurve(_ bytes: [UInt8]) throws -> CurvePoint {
        let fieldElements = try hashToField(bytes, 2)

        let point1 = mapToCurve(fieldElements[0]), point2 = mapToCurve(fieldElements[1])
        let point3 = point1 + point2

        let resultPoint = clearCofactor(point3)
        return resultPoint
    }
}
private extension BLS12_381_SHA_256 {
    func hashToField(_ bytes: [UInt8], _ count: Int) throws -> [[BigUInt]] {
        // 1
        let lengthInBytes = count * m * L

        // 2
        let uniformBytes = try expandMessage(bytes, domainSeparationTag: domainSeparationTagG1, expectedLengthInBytes: lengthInBytes)


        var arrayI: [[BigUInt]] = []

        // 3
        for i in 0..<count {
            var arrayJ: [BigUInt] = []


            // 4
            for j in 0..<m {

                // 5
                let elementOffset = L * (j + i * m)

                // 6
                let tv = Array(uniformBytes[elementOffset..<elementOffset + L])

                // 7
                let e_j = Primitives.bytesToInteger(tv) % p

                arrayJ.append(e_j)
            }

            // 8
            let u_i = Array(arrayJ[0..<m])
            arrayI.append(u_i)



        }

        let res = Array(arrayI[0..<count])
        print(res)
        //print(res.first!.first!.toHexString())

        if res.first!.first!.toHexString() == "0ba14bd907ad64a016293ee7c2d276b8eae71f25a4b941eece7b0d89f17f75cb3ae5438a614fb61d6835ad59f29c564f" {
            print("JEST")
        }


        return res
    }
    func mapToCurve(_ element: Any) -> CurvePoint {
        fatalError()
    }
    func clearCofactor(_ point: CurvePoint) -> CurvePoint {
        fatalError()
    }
}
private extension BLS12_381_SHA_256 {
    var domainSeparationTagG1: [UInt8] { "QUUX-V01-CS02-with-BLS12381G1_XMD:SHA-256_SSWU_RO_".asAsciiToByteRepresentation() }
}

// MARK: - Point to Octets
extension BLS12_381_SHA_256 {
    func pointToOctets_g1(_ point: [UInt8]) -> [UInt8] {
        fatalError()
    }
    func pointToOctets_g2(_ point: [UInt8]) -> [UInt8] { pointToOctets_g1(point) }
}

// MARK: - Octets to Point
extension BLS12_381_SHA_256 {
    func octetsToPoint_g1(_ bytes: [UInt8]) -> [UInt8] {
        fatalError()
    }
    func octetsToPoint_g2(_ bytes: [UInt8]) -> [UInt8] { octetsToPoint_g1(bytes) }
}

// MARK: - Hashing
extension BLS12_381_SHA_256 {
    func hashData(_ bytes: [UInt8]) -> [UInt8] { Hash.sha256(bytes) }
}
private extension BLS12_381_SHA_256 {
    var hashOutputSizeInBytes: Int { 64 }
}


// MARK: - Errors
fileprivate typealias Error = BLS12_381_SHA_256Error
enum BLS12_381_SHA_256Error {
    enum ExpandMessage: Swift.Error { case expectedLengthMustBePositive, expectedLengthTooLarge, domainSeperationTagTooBig, helperArrayTooBig }
}



extension BigUInt {
    func toHexString() -> String { [UInt8](serialize()).toHexRepresentation() }
}
