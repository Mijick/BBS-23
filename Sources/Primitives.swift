//
//  Primitives.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class Primitives { private init() {} }

// MARK: - Converting to and from bytes
extension Primitives {

    /// Also known as OS2IP.
    /// Transforms a octet string into an non-negative integer. The input of this operation must be in big-endian order
    static func bytesToInteger(_ bytes: [UInt8]) -> BInt { .init(magnitude: bytes) }

    /// Also known as I20SP.
    /// Transforms a non-negative integer into an array of bytes
    static func integerToBytes(value: BInt, expectedLength: Int) throws -> [UInt8] {
        try assertIntegerToBytesRequirements(value, expectedLength)

        let value = value.asMagnitudeBytes()
        return createArrayOfExpectedLength(value, expectedLength)
    }
}
private extension Primitives {
    static func assertIntegerToBytesRequirements(_ value: BInt, _ expectedLength: Int) throws {
        if expectedLength < 0 { throw Error.I20SP.negativeExpectedLength }
        if value >= BInt(256) ** expectedLength { throw Error.I20SP.tooLargeInteger }
    }
    static func createArrayOfExpectedLength(_ bytes: [UInt8], _ expectedLength: Int) -> [UInt8] { var bytes = bytes
        let numberOfItemsToInsert = expectedLength - bytes.count
        for _ in 0..<numberOfItemsToInsert { bytes.insert(0, at: 0) }
        return bytes
    }
}


// MARK: - Errors
extension Primitives { enum Error {
    enum I20SP: Swift.Error { case negativeExpectedLength, tooLargeInteger }
}}
