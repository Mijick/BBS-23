//
//  BBSTests.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import XCTest
@testable import MijickBBS_Signature

final class BBSTests: XCTestCase {}

// MARK: - Secret Key Creation
extension BBSTests {
    func testSecretKeyCreation_1() throws {
        let keyMaterial = "746869732d49532d6a7573742d616e2d546573742d494b4d2d746f2d67656e65726174652d246528724074232d6b6579".asHexToByteRepresentation()
        let keyInfo = "746869732d49532d736f6d652d6b65792d6d657461646174612d746f2d62652d757365642d696e2d746573742d6b65792d67656e".asHexToByteRepresentation()

        let generatedSecretKey = try bbs.generateSecretKey(keyMaterial: keyMaterial, keyInfo: keyInfo)
        let expectedSecretKey = "60e55110f76883a13d030b2f6bd11883422d5abde717569fc0731f51237169fc".asHexToByteRepresentation().toInteger()

        XCTAssertEqual(generatedSecretKey, expectedSecretKey)
    }
}

// MARK: - Public Key Creation
extension BBSTests {
    func testPublicKeyCreation_1() throws {
        let secretKey = "60e55110f76883a13d030b2f6bd11883422d5abde717569fc0731f51237169fc".asHexToByteRepresentation().toInteger()

        let generatedPublicKey = try bbs.generatePublicKey(secretKey)
        let expectedPublicKey = "a820f230f6ae38503b86c70dc50b61c58a77e45c39ab25c0652bbaa8fa136f2851bd4781c9dcde39fc9d1d52c9e60268061e7d7632171d91aa8d460acee0e96f1e7c4cfb12d3ff9ab5d5dc91c277db75c845d649ef3c4f63aebc364cd55ded0c".asHexToByteRepresentation()

        XCTAssertEqual(generatedPublicKey, expectedPublicKey)
    }
}

// MARK: - Helpers
private extension BBSTests {
    var bbs: BBS { .init(Cipher.BLS12_381_SHA_256()) }
}
