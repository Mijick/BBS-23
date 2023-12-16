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

class Utilities {
    let ciphersuite: CipherSuite

    init(_ ciphersuite: CipherSuite) { self.ciphersuite = ciphersuite }
}

// MARK: - Creating Generators
extension Utilities {
    func createGenerators(count: BInt, seed: [UInt8]?, apiID: [UInt8]?) throws { let seed = seed ?? defaultGeneratorsSeed, apiID = apiID ?? defaultGeneratorApiID
        if count > BInt(2) ** 64 - 1 { throw Error.CreateGenerators.cannotGenerateThatAmountOfGenerators }

        let seedDst = getSeedDst(apiID),
            generatorDst = getGeneratorDst(apiID),
            generatorSeed = getGeneratorSeed(apiID)





        var v = try ciphersuite.curveG1.expandMessage.make(generatorSeed, domainSeparationTag: seedDst, expectedLengthInBytes: ciphersuite.expandLength)


        //        var generators = []
        //
        //
        //        for i in 1...count {
        //            let uu = v.concatenate(with: i.toBytes(expectedLength: 8))
        //
        //            v = ciphersuite.curve.first!.expandMessage(uu, domainSeparationTag: seedDst, expectedLengthInBytes: ciphersuite.expandLength)
        //
        //            generators.append(ciphersuite.curve.first!.hashToCurve(<#T##bytes: [UInt8]##[UInt8]#>))
        //
        //            // dwie zmiany:
        //            // 1. przenieść expandMessage do ciphersuite
        //            // 2. hashToCurve powinno móc przyjmować opcjonalny argument - DST
        //
        //
        //            let vv = ciphersuite.curve.first!.expandMessage(<#T##[UInt8]#>, domainSeparationTag: <#T##[UInt8]#>, expectedLengthInBytes: <#T##Int#>)
        //        }
    }
}
private extension Utilities {

}
private extension Utilities {
    func getSeedDst(_ apiID: [UInt8]) -> [UInt8] {
        let seed = "SIG_GENERATOR_SEED_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: seed)
    }
    func getGeneratorDst(_ apiID: [UInt8]) -> [UInt8] {
        let generator = "SIG_GENERATOR_DST_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: generator)
    }
    func getGeneratorSeed(_ apiID: [UInt8]) -> [UInt8] {
        let generatorSeed = "MESSAGE_GENERATOR_SEED".asAsciiToByteRepresentation()
        return apiID.concatenate(with: generatorSeed)
    }
}
private extension Utilities {
    var defaultGeneratorsSeed: [UInt8] { [] }
    var defaultGeneratorApiID: [UInt8] { [] }
}


// MARK: - Converting to scalar
extension Utilities {
    static func hashToScalar(_ msg: [UInt8], _ dst: [UInt8], _ ciphersuite: CipherSuite) throws -> BInt {
        guard dst.count * 8 > 255 else { throw Error.ConvertToScalar.invalidDSTLength }

        let uniformBytes = try ciphersuite.curveG1.expandMessage.make(msg, domainSeparationTag: dst, expectedLengthInBytes: ciphersuite.expandLength)
        let number = Primitives.bytesToInteger(uniformBytes)
        return number % ciphersuite.curveG1.r
    }
    static func messagesToScalars(_ messages: [[UInt8]], _ apiId: [UInt8] = [], ciphersuite: CipherSuite) throws -> [BInt] {
        guard messages.count <= BInt(2) ** 64 - 1 else { throw Error.ConvertToScalar.invalidMessageLength }

        let map_dst = apiId.concatenate(with: "MAP_MSG_TO_SCALAR_AS_HASH_".asAsciiToByteRepresentation())
        return try messages.map { try hashToScalar($0, map_dst, ciphersuite) }
    }
}


// MARK: - Errors
fileprivate typealias Error = UtilitiesError
enum UtilitiesError {
    enum CreateGenerators: Swift.Error { case cannotGenerateThatAmountOfGenerators }
    enum ConvertToScalar: Swift.Error { case invalidDSTLength, invalidMessageLength }
}
