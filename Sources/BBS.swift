//
//  BBS.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

class BBS {
    private let cipher: CipherSuite

    public init(_ cipher: CipherSuite) { self.cipher = cipher }
}

// MARK: - Secret Key Generation
extension BBS {
    func generateSecretKey(keyMaterial: [UInt8], keyInfo: [UInt8]? = nil, keyDst: [UInt8]? = nil) throws -> BInt { let keyInfo = keyInfo ?? defaultKeyInfo, keyDst = keyDst ?? defaultKeyDst
        try checkSecretKeyIngredients(keyMaterial, keyInfo)

        let deriveInput = keyMaterial
            .concatenate(with: try BInt(keyInfo.count).toBytes(expectedLength: 2))
            .concatenate(with: keyInfo)

        let secretKey = try Utilities(cipher).hashToScalar(deriveInput, keyDst)
        return secretKey
    }
}
private extension BBS {
    func checkSecretKeyIngredients(_ keyMaterial: [UInt8], _ keyInfo: [UInt8]) throws {
        if keyMaterial.count < 32 { throw Error.SecretKeyGeneration.tooSmallKeyMaterial }
        if keyInfo.count > 65535 { throw Error.SecretKeyGeneration.tooBigKeyInfo }
    }
}
private extension BBS {
    var defaultKeyInfo: [UInt8] { [] }
    var defaultKeyDst: [UInt8] { cipher.id.asAsciiToByteRepresentation().concatenate(with: "H2G_HM2S_KEYGEN_DST_".asAsciiToByteRepresentation()) }

}

// MARK: - Public Generation
extension BBS {
    func generatePublicKey(_ secretKey: BInt) throws -> [UInt8] { let curve = cipher.curveG2, bp2 = curve.getBasePoint()
        let publicKey = secretKey * bp2
        return try curve.serializePoint(publicKey)
    }
}

// MARK: - Signature Generation
extension BBS {
    func generateSignature(secretKey: BInt, publicKey: [UInt8], header: [UInt8] = [], messages: [[UInt8]] = []) throws -> [UInt8] {
        let messageScalars = try utilities.messagesToScalars(messages: messages, apiID: apiID),
            generators = try utilities.createGenerators(count: messages.count + 1, apiID: apiID)

        let signature = try core.coreSign(secretKey: secretKey, publicKey: publicKey, generators: generators, header: header, messages: messageScalars, apiID: apiID)
        return signature
    }
}

// MARK: - Helpers
private extension BBS {
    var apiID: [UInt8] {
        let cipherID = cipher.id.asAsciiToByteRepresentation(), api = "H2G_HM2S_".asAsciiToByteRepresentation()
        return cipherID.concatenate(with: api)
    }
}
private extension BBS {
    var core: Core { .init(cipher) }
    var utilities: Utilities { .init(cipher) }
}


// MARK: - Errors
fileprivate typealias Error = BBSError
enum BBSError {
    enum SecretKeyGeneration: Swift.Error { case tooSmallKeyMaterial, tooBigKeyInfo }
}
