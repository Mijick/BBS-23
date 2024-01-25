//
//  Core.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class Core {}

// MARK: - Core Signature
extension Core {
    static func coreSign(secretKey: BInt, publicKey: [UInt8], generators: [Point<Fq1>], header: [UInt8], messages: [BInt], apiID: [UInt8]) throws -> [UInt8] {
        try checkCoreSignInput(generators, messages)

        let domain = try Utilities.calculateDomain(publicKey: publicKey, generators: generators, header: header, apiID: apiID)

        let scalar = try createScalar(secretKey, domain, messages, apiID)
        let point = createPoint(secretKey, scalar, generators, domain, messages)
        let signature = try Utilities.signatureToOctets(signature: (point, scalar))
        return signature
    }
}
private extension Core {
    static func checkCoreSignInput(_ generators: [Point<Fq1>], _ messages: [BInt]) throws {
        if generators.count < messages.count + 1 { throw Error.CoreSign.tooLessGenerators }
    }
    static func createScalar(_ secretKey: BInt, _ domain: BInt, _ messages: [BInt], _ apiID: [UInt8]) throws -> BInt {
        let signatureDst = getSignatureDst(apiID)

        let serializedScalar = try Utilities.serialize(input: [secretKey, domain] + messages)
        let scalar = try Utilities.hashToScalar(serializedScalar, signatureDst)

        if secretKey == (-scalar).mod(cipher.curveG1.p) { throw Error.CoreSign.insufficientRandomness }
        return scalar
    }
    static func createPoint(_ secretKey: BInt, _ scalar: BInt, _ generators: [Point<Fq1>], _ domain: BInt, _ messages: [BInt]) -> Point<Fq1> {
        let B = getPointB(generators, domain, messages)
        
        let point = B * (secretKey + scalar).modInverse(cipher.r)
        return point
    }
}
private extension Core {
    static func getSignatureDst(_ apiID: [UInt8]) -> [UInt8] {
        let signatureTag = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: signatureTag)
    }
}

// MARK: - Core Signature Verify
extension Core {
    static func coreSignatureVerify(publicKey: [UInt8], signature: [UInt8], generators: [Point<Fq1>], header: [UInt8], messages: [BInt], apiID: [UInt8]) throws -> Bool {
        try checkSignatureVerifyInput(generators, messages)

        let signatureResult = try Utilities.octetsToSignature(signatureOctets: signature)
        let W = try Utilities.octetsToPublicKey(publicKey: publicKey)

        let domain = try Utilities.calculateDomain(publicKey: publicKey, generators: generators, header: header, apiID: apiID)
        let B = getPointB(generators, domain, messages)

        let isSignatureValid = try verifyPointsPairing(signatureResult, W, B)
        return isSignatureValid
    }
}
private extension Core {
    static func checkSignatureVerifyInput(_ generators: [Point<Fq1>], _ messages: [BInt]) throws {
        if generators.count != messages.count + 1 { throw Error.CoreSignVerify.tooLessGenerators }
    }
    static func verifyPointsPairing(_ signature: Signature, _ W: Point<Fq2>, _ B: Point<Fq1>) throws -> Bool {
        let a1 = signature.A
        let a2 = W + cipher.curveG2.getBasePoint() * signature.e
        let e1 = try BilinearPairing(pG1: a1, pG2: a2).pair()

        let b1 = B
        let b2 = -cipher.curveG2.getBasePoint()
        let e2 = try BilinearPairing(pG1: b1, pG2: b2).pair()

        let result = e1 * e2


        


        return false
    }
}

// MARK: - Core Proof Generation
extension Core {
    static func proofGeneration(publicKey: [UInt8], signature: [UInt8], generators: [Point<Fq1>], header: [UInt8], presentationHeader: [UInt8], messages: [BInt], disclosedIndexes: [Int], apiID: [UInt8], mocked: Bool) throws -> [UInt8] {
        try checkProofGenerationEntryData(messages, disclosedIndexes)

        let undisclosedIndexes = getUndisclosedIndexes(messages, disclosedIndexes),
            disclosedMessages = getMessages(messages, disclosedIndexes),
            undisclosedMessages = getMessages(messages, undisclosedIndexes),
            signatureResult = try Utilities.octetsToSignature(signatureOctets: signature),
            randomScalars = try getRandomScalars(messages, disclosedIndexes, mocked)

        let initRes = try proofInit(publicKey: publicKey, signature: signatureResult, generators: generators, randomScalars: randomScalars, header: header, messages: messages, undisclosedIndexes: undisclosedIndexes, apiID: apiID)
        let challenge = try proofChallengeCalculate(initProof: initRes, disclosedMessages: disclosedMessages, disclosedIndexes: disclosedIndexes, presentationHeader: presentationHeader, apiID: apiID)

        let proof = try proofFinalize(initRes: initRes, challenge: challenge, e: signatureResult.e, randomScalars: randomScalars, undisclosedMessages: undisclosedMessages)
        return proof
    }
}
private extension Core {
    static func checkProofGenerationEntryData(_ messages: [BInt], _ disclosedIndexes: [Int]) throws {
        if disclosedIndexes.count > messages.count { throw Error.CoreProof.incorrectDisclosedIndexes }
        if disclosedIndexes.contains(where: { $0 < 0 || $0 >= messages.count }) { throw Error.CoreProof.incorrectDisclosedIndexes }
    }
    static func getUndisclosedIndexes(_ messages: [BInt], _ disclosedIndexes: [Int]) -> [Int] { .init(0..<messages.count).filter { !disclosedIndexes.contains($0) } }
    static func getMessages(_ messages: [BInt], _ indexes: [Int]) -> [BInt] { indexes.reduce(into: []) { $0.append(messages[$1]) } }
    static func getRandomScalars(_ messages: [BInt], _ disclosedIndexes: [Int], _ mocked: Bool) throws -> [BInt] {
        let n = 5 + messages.count - disclosedIndexes.count
        return try mocked ? Utilities.calculateMockedRandomScalars(count: n) : Utilities.calculateRandomScalars(count: n)
    }
}

// MARK: - Proof Init
extension Core {
    static func proofInit(publicKey: [UInt8], signature: Signature, generators: [Point<Fq1>], randomScalars: [BInt], header: [UInt8], messages: [BInt], undisclosedIndexes: [Int], apiID: [UInt8]) throws -> ProofInitVector {
        try checkProofInitEntryData(generators, randomScalars, messages, undisclosedIndexes)

        let domain = try Utilities.calculateDomain(publicKey: publicKey, generators: generators, header: header, apiID: apiID)
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
    static func checkProofInitEntryData(_ generators: [Point<Fq1>], _ randomScalars: [BInt], _ messages: [BInt], _ undisclosedIndexes: [Int]) throws {
        if randomScalars.count != undisclosedIndexes.count + 5 { throw Error.CoreProofInit.tooLessRandomScalars }
        if generators.count != messages.count + 1 { throw Error.CoreProofInit.tooLessGenerators }
        if undisclosedIndexes.count > messages.count { throw Error.CoreProofInit.incorrectUndisclosedIndexes }
        if undisclosedIndexes.contains(where: { $0 < 0 || $0 >= messages.count }) { throw Error.CoreProofInit.incorrectUndisclosedIndexes }
    }
    static func getPointT2(_ D: Point<Fq1>, _ generators: [Point<Fq1>], _ randomScalars: [BInt], _ undisclosedIndexes: [Int]) -> Point<Fq1> {
        let generators = [D] + getGeneratorsForUndisclosedMessages(generators, undisclosedIndexes),
            randomScalars = Array(randomScalars[4..<randomScalars.count])

        var T2 = generators[0] * randomScalars[0]
        for index in 1..<generators.count { T2 = T2 + generators[index] * randomScalars[index] }
        return T2
    }
}
private extension Core {
    static func getGeneratorsForUndisclosedMessages(_ generators: [Point<Fq1>], _ undisclosedIndexes: [Int]) -> [Point<Fq1>] { undisclosedIndexes.reduce(into: []) { $0.append(Array(generators[1..<generators.count])[$1]) } }
}

// MARK: - Proof Challenge Calculation
extension Core {
    static func proofChallengeCalculate(initProof: ProofInitVector, disclosedMessages: [BInt], disclosedIndexes: [Int], presentationHeader: [UInt8], apiID: [UInt8]) throws -> BInt {
        try checkChallengeEntryData(disclosedMessages, disclosedIndexes, presentationHeader)

        let challengeDst = getChallengeDst(apiID)
        let cArr = getChallengeArray(initProof, disclosedMessages, disclosedIndexes)
        let cOcts = try getChallengeOcts(cArr, presentationHeader)

        return try Utilities.hashToScalar(cOcts, challengeDst)
    }
}
private extension Core {
    static func checkChallengeEntryData(_ disclosedMessages: [BInt], _ disclosedIndexes: [Int], _ presentationHeader: [UInt8]) throws {
        if disclosedMessages.count != disclosedIndexes.count { throw Error.Challenge.disclosedMessagesMustBeOfTheSameLengthAsDisclosedIndexes }
        if disclosedIndexes.count > 2 ** 64 - 1 { throw Error.Challenge.tooManyDisclosedIndexes }
        if presentationHeader.count > 2 ** 64 - 1 { throw Error.Challenge.tooBigPresentationHeader }
    }
    static func getChallengeArray(_ initProof: ProofInitVector, _ disclosedMessages: [BInt], _ disclosedIndexes: [Int]) -> [Any] { []
        .appending([initProof.Abar, initProof.Bbar, initProof.D, initProof.T1, initProof.T2])
        .appending([disclosedIndexes.count])
        .appending(disclosedIndexes)
        .appending(disclosedMessages)
        .appending([initProof.domain])
    }
    static func getChallengeOcts(_ array: [Any], _ presentationHeader: [UInt8]) throws -> [UInt8] { try Utilities
        .serialize(input: array)
        .concatenate(with: presentationHeader.count.toBytes(expectedLength: 8))
        .concatenate(with: presentationHeader)
    }
}
private extension Core {
    static func getChallengeDst(_ apiID: [UInt8]) -> [UInt8] {
        let challenge = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: challenge)
    }
}

// MARK: - Proof Finalize
extension Core {
    static func proofFinalize(initRes: ProofInitVector, challenge: BInt, e: BInt, randomScalars: [BInt], undisclosedMessages: [BInt]) throws -> [UInt8] {
        try checkProofFinalizeEntryData(randomScalars, undisclosedMessages)

        let tv1 = randomScalars[1].modInverse(cipher.r)

        let e = (randomScalars[2] + e * challenge).mod(cipher.r)
        let r1 = (randomScalars[3] - randomScalars[0] * challenge).mod(cipher.r)
        let r3 = (randomScalars[4] - tv1 * challenge).mod(cipher.r)
        let m = getMScalars(challenge, randomScalars, undisclosedMessages)

        let proof = (initRes.Abar, initRes.Bbar, initRes.D, e, r1, r3, m, challenge)
        return try Utilities.proofToOctets(proof)
    }
}
private extension Core {
    static func checkProofFinalizeEntryData(_ randomScalars: [BInt], _ undisclosedMessages: [BInt]) throws {
        if randomScalars.count != undisclosedMessages.count + 5 { throw Error.CoreProofFinalize.tooLessRandomScalars }
    }
    static func getMScalars(_ challenge: BInt, _ randomScalars: [BInt], _ undisclosedMessages: [BInt]) -> [BInt] {
        if randomScalars.count < 6 { return [] }

        let randomScalars = Array(randomScalars[5..<randomScalars.count])
        return (0..<randomScalars.count).reduce([]) { $0 + [(randomScalars[$1] + undisclosedMessages[$1] * challenge).mod(cipher.r)] }
    }
}

// MARK: - Helpers
private extension Core {
    static func getPointB(_ generators: [Point<Fq1>], _ domain: BInt, _ messages: [BInt]) -> Point<Fq1> { generators.enumerated().reduce(cipher.p1) { $0 + ($1.element * ([domain] + messages)[$1.offset]) } }
}
private extension Core {
    static var cipher: CipherSuite { BBSSettings.ciphersuite }
}


// MARK: - Errors
extension Core { enum Error {
    enum CoreSign: Swift.Error { case tooLessGenerators, insufficientRandomness }
    enum CoreSignVerify: Swift.Error { case tooLessGenerators }
    enum CoreProof: Swift.Error { case incorrectDisclosedIndexes }
    enum CoreProofInit: Swift.Error { case tooLessRandomScalars, tooLessGenerators, incorrectUndisclosedIndexes }
    enum Challenge: Swift.Error { case disclosedMessagesMustBeOfTheSameLengthAsDisclosedIndexes, tooManyDisclosedIndexes, tooBigPresentationHeader }
    enum CoreProofFinalize: Swift.Error { case tooLessRandomScalars }
}}
