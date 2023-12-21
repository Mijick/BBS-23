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

// MARK: - Core Sign
extension Core {
    func coreSign(secretKey: BInt, publicKey: [UInt8], generators: [CurvePoint], header: [UInt8], messages: [BInt], commitment: CurvePoint, apiID: [UInt8]) throws -> [UInt8] {
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

        let scalarInputArray = [secretKey, domain] + messages
        let serializedScalar = try utilities.serialize(input: scalarInputArray)

        let scalar = try utilities.hashToScalar(serializedScalar, signatureDst)
        if secretKey == (-scalar).mod(ciphersuite.curveG1.p) { throw Error.CoreSign.insufficientRandomness }
        return scalar
    }
    func createPoint(_ secretKey: BInt, _ scalar: BInt, _ generators: [CurvePoint], _ domain: BInt, _ messages: [BInt]) -> CurvePoint {
        var B = ciphersuite.p1

        for index in 0..<generators.count {
            let p1 = generators[index]
            let p2 = ([domain] + messages)[index]

            B = B + (p1 * p2)
        }

        let point = B * (secretKey + scalar).modInverse(ciphersuite.curveG1.p)
        return point
    }
}
private extension Core {
    func getSignatureDst(_ apiID: [UInt8]) -> [UInt8] {
        let signatureTag = "H2S_".asAsciiToByteRepresentation()
        return apiID.concatenate(with: signatureTag)
    }
}

// MARK: - Helpers
private extension Core {
    var utilities: Utilities { .init(ciphersuite) }
}


// MARK: - Errors
fileprivate typealias Error = CoreError
enum CoreError {
    enum CoreSign: Swift.Error { case tooLessGenerators, insufficientRandomness }
}
