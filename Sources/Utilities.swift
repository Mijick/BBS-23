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

// MARK: - Domain Calculation
extension Utilities {
    func calculateDomain(publicKey: [UInt8], points: [CurvePoint], header: [UInt8], apiID: [UInt8]) throws -> BInt {
        try precheckDomainRequirements(points, header)

        let L = points.count - 1,
            domainDst = getDomainDst(apiID)

        let domArray = [L] + points
        let domOcts = try serialize(input: domArray).concatenate(with: apiID)
        let domInput = publicKey
            .concatenate(with: domOcts)
            .concatenate(with: try header.count.toBytes(expectedLength: 8))
            .concatenate(with: header)

        let domain = try hashToScalar(domInput, domainDst)
        return domain
    }
}
private extension Utilities {
    func precheckDomainRequirements(_ points: [CurvePoint], _ header: [UInt8]) throws {
        if points.count < 2 { throw Error.CalculateDomain.tooLessPoints }
        if points.count > 2 ** 64 - 1 { throw Error.CalculateDomain.tooManyPoints }
        if header.count > 2 ** 64 - 1 { throw Error.CalculateDomain.tooBigHeader }
    }
}
private extension Utilities {
    func getDomainDst(_ apiID: [UInt8]) -> [UInt8] {
        let domain = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: domain)
    }
}

// MARK: - Creating Generators
extension Utilities {
    func createGenerators(count: BInt, seed: [UInt8], apiID: [UInt8]) throws -> [CurvePoint] {
        if count > BInt(2) ** 64 - 1 { throw Error.CreateGenerators.cannotGenerateThatAmountOfGenerators }

        // MARK: Parameters
        let seedDst = getSeedDst(apiID),
            generatorDst = getGeneratorDst(apiID),
            generatorSeed = getGeneratorSeed(apiID)

        // MARK: Variables
        var generators: [CurvePoint] = []
        var v = try ciphersuite.expandMessage.make(generatorSeed, dst: seedDst, expectedLengthInBytes: ciphersuite.expandLength)

        // MARK: Creating Generators
        while generators.count < count {
            let bytes = v.concatenate(with: try BInt(generators.count + 1).toBytes(expectedLength: 8))
            v = try ciphersuite.expandMessage.make(bytes, dst: seedDst, expectedLengthInBytes: ciphersuite.expandLength)

            let generatorI = try ciphersuite.curveG1.hashToCurve(v, dst: generatorDst)
            generators.append(generatorI)
        }

        return generators
    }
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

// MARK: - Converting to Scalar
extension Utilities {
    func hashToScalar(_ msg: [UInt8], _ dst: [UInt8]) throws -> BInt {
        guard dst.count * 8 > 255 else { throw Error.ConvertToScalar.invalidDSTLength }

        let uniformBytes = try ciphersuite.curveG1.expandMessage.make(msg, dst: dst, expectedLengthInBytes: ciphersuite.expandLength)
        let number = Primitives.bytesToInteger(uniformBytes)
        return number % ciphersuite.curveG1.r
    }
    func messagesToScalars(_ messages: [[UInt8]], _ apiId: [UInt8] = []) throws -> [BInt] {
        guard messages.count <= BInt(2) ** 64 - 1 else { throw Error.ConvertToScalar.invalidMessageLength }

        let map_dst = apiId.concatenate(with: "MAP_MSG_TO_SCALAR_AS_HASH_".asAsciiToByteRepresentation())
        return try messages.map { try hashToScalar($0, map_dst) }
    }
}

// MARK: - Serializing
extension Utilities {
    func serialize(input: [Any]) throws -> [UInt8] {
        fatalError()
    }
}

// MARK: - Octets to Public Key
extension Utilities {
    func octetsToPublicKey(publicKey: [UInt8]) throws -> CurvePoint {
        let publicKey = try ciphersuite.curveG2.deserializePoint(publicKey)
        try checkPublicKey(publicKey)
        return publicKey
    }
}
private extension Utilities {
    func checkPublicKey(_ publicKey: CurvePoint) throws {
        if !publicKey.isInSubgroup() { throw Error.OctetsToPublicKey.publicKeyIsInWrongSubgroup }
        if publicKey.isAtInfinity() { throw Error.OctetsToPublicKey.publicKeyIsAtInfinity }
    }
}


// MARK: - Errors
fileprivate typealias Error = UtilitiesError
enum UtilitiesError {
    enum CalculateDomain: Swift.Error { case tooLessPoints, tooManyPoints, tooBigHeader }
    enum CreateGenerators: Swift.Error { case cannotGenerateThatAmountOfGenerators }
    enum ConvertToScalar: Swift.Error { case invalidDSTLength, invalidMessageLength }
    enum OctetsToPublicKey: Swift.Error { case publicKeyIsInWrongSubgroup, publicKeyIsAtInfinity }
}
