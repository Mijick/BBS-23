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
    static func bytesToInteger(_ bytes: [UInt8]) -> BigUInt {
        let data = Data(bytes)
        return .init(data)
    }

    /// Also known as I20SP.
    /// Transforms a non-negative integer into an array of bytes
    static func integerToBytes(value: BigUInt, expectedLength: Int) throws -> [UInt8] {
        try assertIntegerToBytesRequirements(value, expectedLength)

        let valueInBase256 = value.serialize()
        let valueAsBytes = [UInt8](valueInBase256)
        return createArrayOfExpectedLength(valueAsBytes, expectedLength)
    }
}
private extension Primitives {
    static func assertIntegerToBytesRequirements(_ value: BigUInt, _ expectedLength: Int) throws {
        if expectedLength < 0 { throw I20SPError.negativeExpectedLength }
        if value >= BigUInt(256).power(expectedLength) { throw I20SPError.tooLargeInteger }
    }
    static func createArrayOfExpectedLength(_ bytes: [UInt8], _ expectedLength: Int) -> [UInt8] { var bytes = bytes
        let numberOfItemsToInsert = expectedLength - bytes.count
        for _ in 0..<numberOfItemsToInsert { bytes.insert(0, at: 0) }
        return bytes
    }
}
