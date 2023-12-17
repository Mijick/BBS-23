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
        var octetsResult: [UInt8] = []

        for element in input {
            let elementOcts = try serializeElement(element)
            octetsResult = octetsResult.concatenate(with: elementOcts)
        }

        return octetsResult
    }
}
private extension Utilities {
    func serializeElement(_ element: Any) throws -> [UInt8] {
        if let point = element as? CurvePoint { return try serializePoint(point) }
        if let integer = element as? BInt { return try serializeInteger(integer) }

        throw Error.Serialization.notValidElement
    }
}
private extension Utilities {
    func serializePoint(_ point: CurvePoint) throws -> [UInt8] {
        if point.isPointOfG1() { return try ciphersuite.curveG1.serializePoint(point) }
        if point.isPointOfG2() { return try ciphersuite.curveG2.serializePoint(point) }

        throw Error.Serialization.notValidElement
    }
    func serializeInteger(_ integer: BInt) throws -> [UInt8] {
        if integer > 0 && integer < 2 ** 64 { return try integer.toBytes(expectedLength: 8) }

        return try integer.toBytes(expectedLength: ciphersuite.octetScalarLength)
    }
}

// MARK: - Random Scalars
extension Utilities {
    func calculateRandomScalars(count: BInt) throws -> [BInt] { let expandLength = ciphersuite.expandLength, r = ciphersuite.curveG2.r
        var randomScalars: [BInt] = []

        while randomScalars.count < count {
            guard let randomScalar = [UInt8]
                .random(length: expandLength)?
                .toInteger()
                .mod(r)
            else { throw Error.RandomScalars.unexpectedErrorDuringGeneratingRandomScalars }

            randomScalars.append(randomScalar)
        }

        return randomScalars
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

// MARK: - Signature to Octets
extension Utilities {
    func signatureToOctets(signature: (point: CurvePoint, scalar: BInt)) throws -> [UInt8] {
        let serializedSignature = try serialize(input: [signature.point, signature.scalar])
        return serializedSignature
    }
}

// MARK: - Octets to Signature
extension Utilities {
    func octetsToSignature(signatureOctets: [UInt8]) throws -> (point: CurvePoint, scalar: BInt) {
        try precheckSignatureOctets(signatureOctets)

        let point = try deserializePoint(signatureOctets)
        let scalar = try deserializeScalar(signatureOctets)

        return (point, scalar)
    }
}
private extension Utilities {
    func precheckSignatureOctets(_ signatureOctets: [UInt8]) throws {
        let expectedLength = ciphersuite.octetPointLength + ciphersuite.octetScalarLength
        if signatureOctets.count != expectedLength { throw Error.OctetsToSignature.invalidSignature }
    }
    func deserializePoint(_ signatureOctets: [UInt8]) throws -> CurvePoint {
        let octets = Array(signatureOctets[0..<ciphersuite.octetPointLength])
        let point = try ciphersuite.curveG1.deserializePoint(octets)

        if point.isAtInfinity() { throw Error.OctetsToSignature.invalidPoint }
        return point
    }
    func deserializeScalar(_ signatureOctets: [UInt8]) throws -> BInt {
        let startIndex = ciphersuite.octetPointLength,
            endIndex = startIndex + ciphersuite.octetScalarLength - 1

        let scalar = Array(signatureOctets[startIndex...endIndex])
            .toInteger()
            .mod(ciphersuite.curveG1.r)

        if scalar == 0 || scalar >= ciphersuite.curveG1.r { throw Error.OctetsToSignature.invalidScalar }
        return scalar
    }
}


// MARK: - Errors
fileprivate typealias Error = UtilitiesError
enum UtilitiesError {
    enum CalculateDomain: Swift.Error { case tooLessPoints, tooManyPoints, tooBigHeader }
    enum CreateGenerators: Swift.Error { case cannotGenerateThatAmountOfGenerators }
    enum ConvertToScalar: Swift.Error { case invalidDSTLength, invalidMessageLength }
    enum Serialization: Swift.Error { case notValidElement }
    enum RandomScalars: Swift.Error { case unexpectedErrorDuringGeneratingRandomScalars }
    enum OctetsToPublicKey: Swift.Error { case publicKeyIsInWrongSubgroup, publicKeyIsAtInfinity }
    enum OctetsToSignature: Swift.Error { case invalidSignature, invalidPoint, invalidScalar }
}
