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
    func expandMessage(_ bytes: [UInt8], domainSeparationTag: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8] {
        let helperBytesArraySize = calculateHelperBytesArraySize(expectedLengthInBytes)
        try assertExpandMessageRequirements(expectedLengthInBytes, domainSeparationTag, helperBytesArraySize)


        // 3 - DOBRZE OBLICZA
        let a = try Primitives.integerToBytes(value: .init(domainSeparationTag.count), expectedLength: 1)
        let dst_prime = domainSeparationTag.concatenate(with: a)


        // 4
        let zPad = try Primitives.integerToBytes(value: 0, expectedLength: hashOutputSizeInBytes)

        // 5
        let l_i_b_str = try Primitives.integerToBytes(value: .init(expectedLengthInBytes), expectedLength: 2)


        // 6
        let b = try Primitives.integerToBytes(value: 0, expectedLength: 1)
        let msg_prime = zPad.concatenate(with: bytes).concatenate(with: l_i_b_str).concatenate(with: b).concatenate(with: dst_prime)

        // 7
        let b_0 = hashData(msg_prime)

        // 8
        let c = try Primitives.integerToBytes(value: 1, expectedLength: 1)
        let d = b_0.concatenate(with: c).concatenate(with: dst_prime)
        let b_1 = hashData(d)


        // 9
        var array: [[UInt8]] = [b_1]
        for i in (0...helperBytesArraySize) {
            let xor = b_0.xor(array[i])
            let e = try Primitives.integerToBytes(value: .init(i + 2), expectedLength: 1)
            let zzz = xor.concatenate(with: e).concatenate(with: dst_prime)
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





// DO ZROBIENIA:
// 1. Zastąpić Primitives za pomocą Extensions


fileprivate typealias Error = BLS12_381_SHA_256Error
