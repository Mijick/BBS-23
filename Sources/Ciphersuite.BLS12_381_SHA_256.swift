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
    let p1: [UInt8] = "a8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9".asHexToByteRepresentation()
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

        // 7
        let b_0 = hashData(messagePrime)

        // 8
        let c = try Primitives.integerToBytes(value: 1, expectedLength: 1)
        let d = b_0.concatenate(with: c).concatenate(with: dstPrime)
        let b_1 = hashData(d)


        // 9
        var array: [[UInt8]] = [b_1]
        for i in (0...helperBytesArraySize) {
            let xor = b_0.xor(array[i])
            let e = try Primitives.integerToBytes(value: .init(i + 2), expectedLength: 1)
            let zzz = xor.concatenate(with: e).concatenate(with: dstPrime)
            let b_i = hashData(zzz)
            array.append(b_i)
        }


        // 10
        let uniformBytes = array.reduce([]) { $0.concatenate(with: $1) }

        // 11
        return .init(uniformBytes[0...expectedLengthInBytes - 1])


        // dodać sprawdzanie czy lengthInBytes != 0
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
}
private extension BLS12_381_SHA_256 {

}



extension BLS12_381_SHA_256 {
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
