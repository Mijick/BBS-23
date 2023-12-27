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
    func createGenerators(count: BInt, apiID: [UInt8]) throws -> [CurvePoint] {
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
            .mod(ciphersuite.curveG1.r)
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
        if let point = element as? CurvePoint { return try serializePoint(point) }
        if let integer = element as? BInt { return try integer.toBytes(expectedLength: ciphersuite.octetScalarLength) }
        if let integer = element as? Int { return try integer.toBytes(expectedLength: 8) }

        throw Error.Serialization.notValidElement
    }
}
private extension Utilities {
    func serializePoint(_ point: CurvePoint) throws -> [UInt8] {
        if point.isPointOfG1() { return try ciphersuite.curveG1.serializePoint(point) }
        if point.isPointOfG2() { return try ciphersuite.curveG2.serializePoint(point) }

        throw Error.Serialization.notValidElement
    }
}

// MARK: - Random Scalars
extension Utilities {
    func calculateRandomScalars(count: BInt) throws -> [BInt] { let expandLength = ciphersuite.expandLength, r = ciphersuite.curveG2.r
        var randomScalars: [BInt] = [
            "60ca409f6b0563f687fc471c63d2819f446f39c23bb540925d9d4254ac58f337",
            "2ceff4982de0c913090f75f081df5ec594c310bb48c17cfdaab5332a682ef811",
            "6101c4404895f3dff87ab39c34cb995af07e7139e6b3847180ffdd1bc8c313cd",
            "0dfcffd97a6ecdebef3c9c114b99d7a030c998d938905f357df62822dee072e8",
            "639e3417007d38e5d34ba8c511e836768ddc2669fdd3faff5c14ad27ac2b2da1",


            
            "4d99352986a9f8978b93485d21525244b21b396cf61f1d71f7c48e3fbc970a42",

            "5ed8be91662386243a6771fbdd2c627de31a44220e8d6f745bad5d99821a4880",
            "62ff1734b939ddd87beeb37a7bbcafa0a274cbc1b07384198f0e88398272208d",
            "05c2a0af016df58e844db8944082dcaf434de1b1e2e7136ec8a99b939b716223",
            "485e2adab17b76f5334c95bf36c03ccf91cef77dcfcdc6b8a69e2090b3156663"



        ]

//        while randomScalars.count < count {
//            guard let randomScalar = [UInt8]
//                .random(length: expandLength)?
//                .toInteger()
//                .mod(r)
//            else { throw Error.RandomScalars.unexpectedErrorDuringGeneratingRandomScalars }
//
//            randomScalars.append(randomScalar)
//        }

        return Array(randomScalars[0..<count.asInt()!])
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

}
private extension Utilities {
    
}


// MARK: - Errors
fileprivate typealias Error = UtilitiesError
enum UtilitiesError {
    enum CalculateDomain: Swift.Error { case tooLessPoints, tooManyPoints, tooBigHeader }
    enum CreateGenerators: Swift.Error { case cannotGenerateThatAmountOfGenerators }
    enum ConvertToScalar: Swift.Error { case invalidDSTLength, invalidMessageLength }
    enum Serialization: Swift.Error { case notValidElement }
    enum RandomScalars: Swift.Error { case unexpectedErrorDuringGeneratingRandomScalars }
    enum OctetsToPublicKey: Swift.Error { case publicKeyInvalid }
    enum OctetsToSignature: Swift.Error { case invalidSignature, invalidPoint, invalidScalar }
}
