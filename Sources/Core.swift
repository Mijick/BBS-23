//
//  Core.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class Core {
    let ciphersuite: CipherSuite

    init(_ ciphersuite: CipherSuite) { self.ciphersuite = ciphersuite }
}

// MARK: - Core Signature
extension Core {
    func coreSign(secretKey: BInt, publicKey: [UInt8], generators: [CurvePoint], header: [UInt8], messages: [BInt], apiID: [UInt8]) throws -> [UInt8] {
        try checkCoreSignInput(generators, messages)

        let domain = try utilities.calculateDomain(publicKey: publicKey, points: generators, header: header, apiID: apiID)

        let scalar = try createScalar(secretKey, domain, messages, apiID)
        let point = createPoint(secretKey, scalar, generators, domain, messages)
        let signature = try utilities.signatureToOctets(signature: (point, scalar))
        return signature
    }
}
private extension Core {
    func checkCoreSignInput(_ generators: [CurvePoint], _ messages: [BInt]) throws {
        if generators.count < messages.count + 1 { throw Error.CoreSign.tooLessGenerators }
    }
    func createScalar(_ secretKey: BInt, _ domain: BInt, _ messages: [BInt], _ apiID: [UInt8]) throws -> BInt {
        let signatureDst = getSignatureDst(apiID)

        let serializedScalar = try utilities.serialize(input: [secretKey, domain] + messages)
        let scalar = try utilities.hashToScalar(serializedScalar, signatureDst)

        if secretKey == (-scalar).mod(ciphersuite.curveG1.p) { throw Error.CoreSign.insufficientRandomness }
        return scalar
    }
    func createPoint(_ secretKey: BInt, _ scalar: BInt, _ generators: [CurvePoint], _ domain: BInt, _ messages: [BInt]) -> CurvePoint {
        let B = getPointB(generators, domain, messages)
        
        let point = B * (secretKey + scalar).modInverse(ciphersuite.curveG1.r)
        return point
    }
}
private extension Core {
    func getSignatureDst(_ apiID: [UInt8]) -> [UInt8] {
        let signatureTag = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: signatureTag)
    }
}

// MARK: - Core Proof Generation
extension Core {
    func proofGeneration(publicKey: [UInt8], signature: [UInt8], generators: [CurvePoint], header: [UInt8], presentationHeader: [UInt8], messages: [BInt], disclosedIndexes: [Int], apiID: [UInt8], mocked: Bool) throws -> [UInt8] {
        try checkProofGenerationEntryData(messages, disclosedIndexes)

        let undisclosedIndexes = getUndisclosedIndexes(messages, disclosedIndexes),
            disclosedMessages = getMessages(messages, disclosedIndexes),
            undisclosedMessages = getMessages(messages, undisclosedIndexes),
            signatureResult = try utilities.octetsToSignature(signatureOctets: signature),
            randomScalars = try getRandomScalars(messages, disclosedIndexes, mocked)

        let initRes = try proofInit(publicKey: publicKey, signature: signatureResult, generators: generators, randomScalars: randomScalars, header: header, messages: messages, undisclosedIndexes: undisclosedIndexes, apiID: apiID)
        let challenge = try proofChallengeCalculate(initProof: initRes, disclosedMessages: disclosedMessages, disclosedIndexes: disclosedIndexes, presentationHeader: presentationHeader, apiID: apiID)

        let proof = try proofFinalize(initRes: initRes, challenge: challenge, e: signatureResult.e, randomScalars: randomScalars, undisclosedMessages: undisclosedMessages)
        return proof
    }
}
private extension Core {
    func checkProofGenerationEntryData(_ messages: [BInt], _ disclosedIndexes: [Int]) throws {
        if disclosedIndexes.count > messages.count { throw Error.CoreProof.incorrectDisclosedIndexes }
        if disclosedIndexes.contains(where: { $0 < 0 || $0 >= messages.count }) { throw Error.CoreProof.incorrectDisclosedIndexes }
    }
    func getUndisclosedIndexes(_ messages: [BInt], _ disclosedIndexes: [Int]) -> [Int] { .init(0..<messages.count).filter { !disclosedIndexes.contains($0) } }
    func getMessages(_ messages: [BInt], _ indexes: [Int]) -> [BInt] { indexes.reduce(into: []) { $0.append(messages[$1]) } }
    func getRandomScalars(_ messages: [BInt], _ disclosedIndexes: [Int], _ mocked: Bool) throws -> [BInt] {
        let n = 5 + messages.count - disclosedIndexes.count
        return try mocked ? utilities.calculateMockedRandomScalars(count: n) : utilities.calculateRandomScalars(count: n)
    }
}

// MARK: - Proof Init
extension Core {
    func proofInit(publicKey: [UInt8], signature: Signature, generators: [CurvePoint], randomScalars: [BInt], header: [UInt8], messages: [BInt], undisclosedIndexes: [Int], apiID: [UInt8]) throws -> ProofInitVector {
        try checkProofInitEntryData(generators, randomScalars, messages, undisclosedIndexes)

        let domain = try utilities.calculateDomain(publicKey: publicKey, points: generators, header: header, apiID: apiID)
        let B = getPointB(generators, domain, messages)

        let D = B * randomScalars[1]
        let Abar = signature.A * randomScalars[0] * randomScalars[1]
        let Bbar = D * randomScalars[0] - Abar * signature.e
        let T1 = Abar * randomScalars[2] + D * randomScalars[3]
        let T2 = getPointT2(D, generators, randomScalars, undisclosedIndexes)
        return (Abar, Bbar, D, T1, T2, domain)
    }
}
private extension Core {
    func checkProofInitEntryData(_ generators: [CurvePoint], _ randomScalars: [BInt], _ messages: [BInt], _ undisclosedIndexes: [Int]) throws {
        if randomScalars.count != undisclosedIndexes.count + 5 { throw Error.CoreProofInit.tooLessRandomScalars }
        if generators.count != messages.count + 1 { throw Error.CoreProofInit.tooLessGenerators }
        if undisclosedIndexes.count > messages.count { throw Error.CoreProofInit.incorrectUndisclosedIndexes }
        if undisclosedIndexes.contains(where: { $0 < 0 || $0 >= messages.count }) { throw Error.CoreProofInit.incorrectUndisclosedIndexes }
    }
    func getPointT2(_ D: CurvePoint, _ generators: [CurvePoint], _ randomScalars: [BInt], _ undisclosedIndexes: [Int]) -> CurvePoint {
        let generators = [D] + getGeneratorsForUndisclosedMessages(generators, undisclosedIndexes),
            randomScalars = Array(randomScalars[4..<randomScalars.count])

        var T2 = generators[0] * randomScalars[0]
        for index in 1..<generators.count { T2 = T2 + generators[index] * randomScalars[index] }
        return T2
    }
}
private extension Core {
    func getGeneratorsForUndisclosedMessages(_ generators: [CurvePoint], _ undisclosedIndexes: [Int]) -> [CurvePoint] { undisclosedIndexes.reduce(into: []) { $0.append(Array(generators[1..<generators.count])[$1]) } }
}

// MARK: - Proof Challenge Calculation
extension Core {
    func proofChallengeCalculate(initProof: ProofInitVector, disclosedMessages: [BInt], disclosedIndexes: [Int], presentationHeader: [UInt8], apiID: [UInt8]) throws -> BInt {
        try checkChallengeEntryData(disclosedMessages, disclosedIndexes, presentationHeader)

        let challengeDst = getChallengeDst(apiID)
        let cArr = getChallengeArray(initProof, disclosedMessages, disclosedIndexes)
        let cOcts = try getChallengeOcts(cArr, presentationHeader)

        return try utilities.hashToScalar(cOcts, challengeDst)
    }
}
private extension Core {
    func checkChallengeEntryData(_ disclosedMessages: [BInt], _ disclosedIndexes: [Int], _ presentationHeader: [UInt8]) throws {
        if disclosedMessages.count != disclosedIndexes.count { throw Error.Challenge.disclosedMessagesMustBeOfTheSameLengthAsDisclosedIndexes }
        if disclosedIndexes.count > 2 ** 64 - 1 { throw Error.Challenge.tooManyDisclosedIndexes }
        if presentationHeader.count > 2 ** 64 - 1 { throw Error.Challenge.tooBigPresentationHeader }
    }
    func getChallengeArray(_ initProof: ProofInitVector, _ disclosedMessages: [BInt], _ disclosedIndexes: [Int]) -> [Any] { []
        .appending([initProof.Abar, initProof.Bbar, initProof.D, initProof.T1, initProof.T2])
        .appending([disclosedIndexes.count])
        .appending(disclosedIndexes)
        .appending(disclosedMessages)
        .appending([initProof.domain])
    }
    func getChallengeOcts(_ array: [Any], _ presentationHeader: [UInt8]) throws -> [UInt8] { try utilities
        .serialize(input: array)
        .concatenate(with: presentationHeader.count.toBytes(expectedLength: 8))
        .concatenate(with: presentationHeader)
    }
}
private extension Core {
    func getChallengeDst(_ apiID: [UInt8]) -> [UInt8] {
        let challenge = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: challenge)
    }
}

// MARK: - Proof Finalize
extension Core {
    func proofFinalize(initRes: ProofInitVector, challenge: BInt, e: BInt, randomScalars: [BInt], undisclosedMessages: [BInt]) throws -> [UInt8] {
        try checkProofFinalizeEntryData(randomScalars, undisclosedMessages)

        let tv1 = randomScalars[1].modInverse(ciphersuite.r)

        let e = (randomScalars[2] + e * challenge).mod(ciphersuite.r)
        let r1 = (randomScalars[3] - randomScalars[0] * challenge).mod(ciphersuite.r)
        let r3 = (randomScalars[4] - tv1 * challenge).mod(ciphersuite.r)
        let m = getMScalars(challenge, randomScalars, undisclosedMessages)

        let proof = (initRes.Abar, initRes.Bbar, initRes.D, e, r1, r3, m, challenge)
        return try utilities.proofToOctets(proof)
    }

}
private extension Core {
    func checkProofFinalizeEntryData(_ randomScalars: [BInt], _ undisclosedMessages: [BInt]) throws {
        if randomScalars.count != undisclosedMessages.count + 5 { throw Error.CoreProofFinalize.tooLessRandomScalars }
    }
    func getMScalars(_ challenge: BInt, _ randomScalars: [BInt], _ undisclosedMessages: [BInt]) -> [BInt] { 
        if randomScalars.count < 6 { return [] }

        let randomScalars = Array(randomScalars[5..<randomScalars.count])
        return (0..<randomScalars.count).reduce([]) { $0 + [(randomScalars[$1] + undisclosedMessages[$1] * challenge).mod(ciphersuite.r)] }
    }
}

// MARK: - Helpers
private extension Core {
    func getPointB(_ generators: [CurvePoint], _ domain: BInt, _ messages: [BInt]) -> CurvePoint { generators.enumerated().reduce(ciphersuite.p1) { $0 + ($1.element * ([domain] + messages)[$1.offset]) } }
}
private extension Core {
    var utilities: Utilities { .init(ciphersuite) }
}


// MARK: - Errors
fileprivate typealias Error = CoreError
enum CoreError {
    enum CoreSign: Swift.Error { case tooLessGenerators, insufficientRandomness }
    enum CoreProof: Swift.Error { case incorrectDisclosedIndexes }
    enum CoreProofInit: Swift.Error { case tooLessRandomScalars, tooLessGenerators, incorrectUndisclosedIndexes }
    enum Challenge: Swift.Error { case disclosedMessagesMustBeOfTheSameLengthAsDisclosedIndexes, tooManyDisclosedIndexes, tooBigPresentationHeader }
    enum CoreProofFinalize: Swift.Error { case tooLessRandomScalars }
}
