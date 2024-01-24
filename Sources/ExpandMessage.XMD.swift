//
//  ExpandMessage.XMD.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

extension ExpandMessage { struct XMD: MessageExpander {
    let hasher: HashType
}}
extension ExpandMessage.XMD {
    func make(_ messageBytes: [UInt8], dst: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8] {
        let helperBytesArraySize = calculateHelperBytesArraySize(expectedLengthInBytes)

        try assertExpandMessageRequirements(expectedLengthInBytes, dst, helperBytesArraySize)

        let dstPrime = try calculateDomainSeparationTagPrime(dst)
        let zPad = try 0.toBytes(expectedLength: hasher.sInBytes)
        let expectedLengthBytes = try expectedLengthInBytes.toBytes(expectedLength: 2)
        let messagePrime = try calculateMessageBytesPrime(messageBytes, dstPrime, zPad, expectedLengthBytes)
        let hashedMessagePrime = hasher.hashData(messagePrime)

        var helperBytesArray = try createHelperBytesArray(hashedMessagePrime, dstPrime)
        try populateHelperBytesArray(&helperBytesArray, helperBytesArraySize, hashedMessagePrime, dstPrime)

        let uniformBytes = helperBytesArray.reduce([]) { $0.concatenate(with: $1) }
        return .init(uniformBytes[0...expectedLengthInBytes - 1])
    }
}
private extension ExpandMessage.XMD {
    func calculateHelperBytesArraySize(_ expectedLengthInBytes: Int) -> Int {
        let expectedLengthInBytes = Double(expectedLengthInBytes), hashOutputSizeInBytes = Double(hasher.bInBytes)

        let result = expectedLengthInBytes / hashOutputSizeInBytes
        return .init(ceil(result))
    }
    func assertExpandMessageRequirements(_ expectedLengthInBytes: Int, _ domainSeparationTag: [UInt8], _ helperBytesArraySize: Int) throws {
        if expectedLengthInBytes <= 0 { throw Error.expectedLengthMustBePositive }
        if expectedLengthInBytes > 65535 { throw Error.expectedLengthTooLarge }
        if domainSeparationTag.count > 255 { throw Error.domainSeperationTagTooBig }
        if helperBytesArraySize > 255 { throw Error.helperArrayTooBig }
    }
    func calculateDomainSeparationTagPrime(_ domainSeparationTag: [UInt8]) throws -> [UInt8] {
        let bytes = try domainSeparationTag.count.toBytes(expectedLength: 1)
        return domainSeparationTag.concatenate(with: bytes)
    }
    func calculateMessageBytesPrime(_ messageBytes: [UInt8], _ dstPrime: [UInt8], _ zPad: [UInt8], _ expectedLengthBytes: [UInt8]) throws -> [UInt8] {
        let bytes = try 0.toBytes(expectedLength: 1)
        return zPad
            .concatenate(with: messageBytes)
            .concatenate(with: expectedLengthBytes)
            .concatenate(with: bytes)
            .concatenate(with: dstPrime)
    }
    func createHelperBytesArray(_ hashedMessagePrime: [UInt8], _ dstPrime: [UInt8]) throws -> [[UInt8]] {
        let byte = try 1.toBytes(expectedLength: 1)
        let firstByte = hashedMessagePrime
            .concatenate(with: byte)
            .concatenate(with: dstPrime)

        let hashedFirstByte = hasher.hashData(firstByte)
        return [hashedFirstByte]
    }
    func populateHelperBytesArray(_ helperBytesArray: inout [[UInt8]], _ expectedSize: Int, _ hashedMessagePrime: [UInt8], _ dstPrime: [UInt8]) throws { for index in 0...expectedSize {
        let indexBytes = try (index + 2).toBytes(expectedLength: 1)
        let xorResult = hashedMessagePrime.xor(helperBytesArray[index])
        let byte = xorResult
            .concatenate(with: indexBytes)
            .concatenate(with: dstPrime)

        let hashedByte = hasher.hashData(byte)
        helperBytesArray.append(hashedByte)
    }}
}


// MARK: - Errors
fileprivate typealias Error = ExpandMessageXMDError
enum ExpandMessageXMDError: Swift.Error { case expectedLengthMustBePositive, expectedLengthTooLarge, domainSeperationTagTooBig, helperArrayTooBig }
