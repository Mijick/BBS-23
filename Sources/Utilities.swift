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
    func calculateDomain(publicKey: [UInt8], generators: [CurvePoint<Fq1>], header: [UInt8], apiID: [UInt8]) throws -> BInt {
        try precheckDomainRequirements(generators, header)

        let L = generators.count - 1,
            domainDst = getDomainDst(apiID)

        let domArray = [L] + generators
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
    func precheckDomainRequirements(_ points: [CurvePoint<Fq1>], _ header: [UInt8]) throws {
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
    func createGenerators(count: BInt, apiID: [UInt8]) throws -> [CurvePoint<Fq1>] {
        if count > BInt(2) ** 64 - 1 { throw Error.CreateGenerators.cannotGenerateThatAmountOfGenerators }

        // MARK: Parameters
        let seedDst = getSeedDst(apiID),
            generatorDst = getGeneratorDst(apiID),
            generatorSeed = getGeneratorSeed(apiID)

        // MARK: Variables
        var generators: [CurvePoint<Fq1>] = []
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
    func messagesToScalars(messages: [[UInt8]], apiID: [UInt8]) throws -> [BInt] {
        if messages.count > 2 ** 64 - 1 { throw Error.ConvertToScalar.invalidMessageLength }

        let mapDst = getMapDst(apiID)
        return try messages.map { try hashToScalar($0, mapDst) }
    }
    func hashToScalar(_ msg: [UInt8], _ dst: [UInt8]) throws -> BInt {
        if dst.count > 255 { throw Error.ConvertToScalar.invalidDSTLength }

        let uniformBytes = try ciphersuite.curveG1.expandMessage.make(msg, dst: dst, expectedLengthInBytes: ciphersuite.expandLength)
        return uniformBytes
            .toInteger()
            .mod(ciphersuite.r)
    }
}
private extension Utilities {
    func getMapDst(_ apiID: [UInt8]) -> [UInt8] {
        let mapDst = "MAP_MSG_TO_SCALAR_AS_HASH_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: mapDst)
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
        if let pointG1 = element as? CurvePoint<Fq1> { return try ciphersuite.curveG1.serializePoint(pointG1) }
        if let pointG2 = element as? CurvePoint<Fq2> { return try ciphersuite.curveG2.serializePoint(pointG2) }
        if let integer = element as? BInt { return try integer.toBytes(expectedLength: ciphersuite.octetScalarLength) }
        if let integer = element as? Int { return try integer.toBytes(expectedLength: 8) }

        throw Error.Serialization.notValidElement
    }
}

// MARK: - Random Scalars
extension Utilities {
    func calculateRandomScalars(count: Int) throws -> [BInt] {
        try (1...count).map { _ in
            guard let result = [UInt8]
                .random(length: ciphersuite.expandLength)?
                .toInteger()
                .mod(ciphersuite.r)
            else { throw Error.RandomScalars.unexpectedErrorDuringGeneratingRandomScalars }

            return result
        }
    }
    func calculateMockedRandomScalars(count: Int) throws -> [BInt] {
        let outLength = ciphersuite.expandLength * count,
            v = try ciphersuite.expandMessage.make(mockedRandomScalarsSeed, dst: mockedRandomScalarsDst, expectedLengthInBytes: outLength)

        return (1...count).reduce([]) {
            let startIndex = ($1 - 1) * ciphersuite.expandLength
            let endIndex = $1 * ciphersuite.expandLength - 1

            let result = Array(v[startIndex...endIndex])
                .toInteger()
                .mod(ciphersuite.r)
            return $0 + [result]
        }
    }
}
private extension Utilities {
    var mockedRandomScalarsSeed: [UInt8] { "332e313431353932363533353839373933323338343632363433333833323739".asHexToByteRepresentation() }
    var mockedRandomScalarsDst: [UInt8] { "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_MOCK_RANDOM_SCALARS_DST_".asAsciiToByteRepresentation() }
}

// MARK: - Octets to Public Key
extension Utilities {
    func octetsToPublicKey(publicKey: [UInt8]) throws -> CurvePoint<Fq2> {
        let publicKey = try ciphersuite.curveG2.deserializePoint(publicKey)
        try checkPublicKey(publicKey)
        return publicKey
    }
}
private extension Utilities {
    func checkPublicKey(_ publicKey: CurvePoint<Fq2>) throws {
        if publicKey.isAtInfinity() { throw Error.OctetsToPublicKey.publicKeyInvalid }
    }
}

// MARK: - Signature to Octets
extension Utilities {
    func signatureToOctets(signature: Signature) throws -> [UInt8] {
        let serializedSignature = try serialize(input: [signature.A, signature.e])
        return serializedSignature
    }
}

// MARK: - Octets to Signature
extension Utilities {
    func octetsToSignature(signatureOctets: [UInt8]) throws -> Signature {
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
    func deserializePoint(_ signatureOctets: [UInt8]) throws -> CurvePoint<Fq1> {
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
            .mod(ciphersuite.r)

        if scalar == 0 || scalar >= ciphersuite.r { throw Error.OctetsToSignature.invalidScalar }
        return scalar
    }
}

// MARK: - Proof to Octets
extension Utilities {
    func proofToOctets(_ proof: Proof) throws -> [UInt8] {
        let array = getProofSerializationArray(proof)
        return try serialize(input: array)
    }
}
private extension Utilities {
    func getProofSerializationArray(_ proof: Proof) -> [Any] { []
        .appending([proof.Abar, proof.Bbar, proof.D])
        .appending([proof.e, proof.r1, proof.r3])
        .appending(proof.m)
        .appending([proof.challenge])
    }
}

// MARK: - Octets to Proof
extension Utilities {
    func octetsToProof(proofOctets: [UInt8]) throws -> Proof {
        try precheckProofOctets(proofOctets)

        var index = 0

        var points: [CurvePoint<Fq1>] = []
        for i in 0...2 {
            let endIndex = index + ciphersuite.octetPointLength - 1
            let Ai = try ciphersuite.curveG1.deserializePoint(Array(proofOctets[index...endIndex]))
            if Ai.isAtInfinity() { throw Error.OctetsToProof.invalidPoint }


            // subgroup check jeszcze


            points.append(Ai)
            index += ciphersuite.octetPointLength
        }

        var j = 0

        var scalars: [BInt] = []
        while index < proofOctets.count {
            let endIndex = index + ciphersuite.octetScalarLength - 1
            let sJ = Array(proofOctets[index...endIndex]).toInteger()
            if sJ == 0 || sJ >= ciphersuite.r { throw Error.OctetsToProof.invalidScalar }

            scalars.append(sJ)

            index += ciphersuite.octetScalarLength
            j += 1
        }


        if index != proofOctets.count { fatalError() }


        return (points[0], points[1], points[2], scalars[0], scalars[1], scalars[2], Array(scalars[3..<scalars.count - 1]), scalars.last!)
    }

}
private extension Utilities {
    func precheckProofOctets(_ proofOctets: [UInt8]) throws {
        let expectedLength = 3 * ciphersuite.octetPointLength + 4 * ciphersuite.octetScalarLength
        if proofOctets.count < expectedLength { throw Error.OctetsToProof.invalidProof }
    }
}


// MARK: - Errors
extension Utilities { enum Error {
    enum CalculateDomain: Swift.Error { case tooLessPoints, tooManyPoints, tooBigHeader }
    enum CreateGenerators: Swift.Error { case cannotGenerateThatAmountOfGenerators }
    enum ConvertToScalar: Swift.Error { case invalidDSTLength, invalidMessageLength }
    enum Serialization: Swift.Error { case notValidElement }
    enum RandomScalars: Swift.Error { case unexpectedErrorDuringGeneratingRandomScalars }
    enum OctetsToPublicKey: Swift.Error { case publicKeyInvalid }
    enum OctetsToSignature: Swift.Error { case invalidSignature, invalidPoint, invalidScalar }
    enum OctetsToProof: Swift.Error { case invalidProof, invalidPoint, invalidScalar }
}}
