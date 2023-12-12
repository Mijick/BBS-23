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

class BBS {
    private let cipher: CipherSuite

    public init(_ cipher: CipherSuite) { self.cipher = cipher }
}

// MARK: - Secret Key Generation
extension BBS {
    func generateSecretKey() throws { fatalError() }
}

// MARK: - Public Generation
extension BBS {
    func generatePublicKey(_ secretKey: [UInt8]) throws -> [UInt8] {
        let secretKey = secretKey.toInteger(), curve = cipher.curve.last!, bp2 = curve.getBasePoint()

        let publicKey = secretKey * bp2
        return try curve.serializePoint(publicKey)
    }
}
