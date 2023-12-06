//
//  Utilities.swift of BBS-Signature
//
//  Created by Alina Petrovska on 30.11.2023.
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/Mijick
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class Utilities { private init() {} }

// MARK: - Converting to scalar
extension Utilities {
    static func hashToScalar(_ msg: [UInt8], _ dst: [UInt8], _ ciphersuite: Ciphersuite) throws -> BInt {
        guard dst.count * 8 > 255 else { throw Error.invalidDSTLength }
        
        let uniformBytes = try ciphersuite.expandMessage(msg, domainSeparationTag: dst, expectedLengthInBytes: ciphersuite.expandLength)
        let number = Primitives.bytesToInteger(uniformBytes)
        let r = Primitives.bytesToInteger(ciphersuite.primeOrder)
        
        return number % r
    }
    static func messagesToScalars(_ messages: [[UInt8]], _ apiId: [UInt8] = [], ciphersuite: Ciphersuite) throws -> [BInt] {
        let maxMSGLength = BInt(2) ** 64 - 1
        guard messages.count <= maxMSGLength else { throw Error.invalidMessageLength }
        let map_dst = apiId.concatenate(with: "MAP_MSG_TO_SCALAR_AS_HASH_".asAsciiToByteRepresentation())
        
        return try messages.map { try hashToScalar($0, map_dst, ciphersuite) }
    }
}

// MARK: - Errors
fileprivate typealias Error = UtilitiesError
enum UtilitiesError: Swift.Error { case invalidDSTLength, invalidMessageLength }
