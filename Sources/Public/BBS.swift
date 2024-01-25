//
//  BBS.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class BBS {}

// MARK: - SDK Setup
extension BBS {
    static func set(ciphersuite: CipherSuite) { BBSSettings.ciphersuite = ciphersuite }
}

// MARK: - Secret Key Generation
extension BBS {
    static func generateSecretKey(keyMaterial: [UInt8], keyInfo: [UInt8]? = nil, keyDst: [UInt8]? = nil) throws -> BInt { let keyInfo = keyInfo ?? defaultKeyInfo, keyDst = keyDst ?? defaultKeyDst
        try checkSecretKeyIngredients(keyMaterial, keyInfo)

        let deriveInput = keyMaterial
            .concatenate(with: try BInt(keyInfo.count).toBytes(expectedLength: 2))
            .concatenate(with: keyInfo)

        let secretKey = try utilities.hashToScalar(deriveInput, keyDst)
        return secretKey
    }
}
private extension BBS {
    static func checkSecretKeyIngredients(_ keyMaterial: [UInt8], _ keyInfo: [UInt8]) throws {
        if keyMaterial.count < 32 { throw Error.SecretKeyGeneration.tooSmallKeyMaterial }
        if keyInfo.count > 65535 { throw Error.SecretKeyGeneration.tooBigKeyInfo }
    }
}
private extension BBS {
    static var defaultKeyInfo: [UInt8] { [] }
    static var defaultKeyDst: [UInt8] { cipher.id.asAsciiToByteRepresentation().concatenate(with: "H2G_HM2S_KEYGEN_DST_".asAsciiToByteRepresentation()) }
}

// MARK: - Public Generation
extension BBS {
    static func generatePublicKey(_ secretKey: BInt) throws -> [UInt8] { let curve = cipher.curveG2, bp2 = curve.getBasePoint()
        let publicKey = secretKey * bp2
        return try curve.serializePoint(publicKey)
    }
}

// MARK: - Signature Generation
extension BBS {
    static func generateSignature(secretKey: BInt, publicKey: [UInt8], header: [UInt8] = [], messages: [[UInt8]] = []) throws -> [UInt8] {
        let messageScalars = try utilities.messagesToScalars(messages: messages, apiID: apiID),
            generators = try utilities.createGenerators(count: messages.count + 1, apiID: apiID)

        let signature = try core.coreSign(secretKey: secretKey, publicKey: publicKey, generators: generators, header: header, messages: messageScalars, apiID: apiID)
        return signature
    }
}

// MARK: - Signature Verification
extension BBS {
    static func verifySignature(publicKey: [UInt8], signature: [UInt8], header: [UInt8], messages: [[UInt8]]) throws -> Bool {
        let messageScalars = try utilities.messagesToScalars(messages: messages, apiID: apiID),
            generators = try utilities.createGenerators(count: messages.count + 1, apiID: apiID)

        let result = try core.coreSignatureVerify(publicKey: publicKey, signature: signature, generators: generators, header: header, messages: messageScalars, apiID: apiID)
        return result
    }
}

// MARK: - Proof Generation
extension BBS {
    static func generateProof(publicKey: [UInt8], signature: [UInt8], header: [UInt8], presentationHeader: [UInt8], messages: [[UInt8]], disclosedIndexes: [Int], mocked: Bool = false) throws -> [UInt8] {
        let messageScalars = try utilities.messagesToScalars(messages: messages, apiID: apiID)
        let generators = try utilities.createGenerators(count: messages.count + 1, apiID: apiID)

        let proof = try core.proofGeneration(publicKey: publicKey, signature: signature, generators: generators, header: header, presentationHeader: presentationHeader, messages: messageScalars, disclosedIndexes: disclosedIndexes, apiID: apiID, mocked: mocked)
        return proof
    }
}

// MARK: - Helpers
private extension BBS {
    static var apiID: [UInt8] {
        let cipherID = cipher.id.asAsciiToByteRepresentation(), api = "H2G_HM2S_".asAsciiToByteRepresentation()
        return cipherID.concatenate(with: api)
    }
}
private extension BBS {
    static var cipher: CipherSuite { BBSSettings.ciphersuite }
    static var core: Core { .init() }
    static var utilities: Utilities { .init() }
}


// MARK: - Errors
extension BBS { enum Error {
    enum SecretKeyGeneration: Swift.Error { case tooSmallKeyMaterial, tooBigKeyInfo }
}}
