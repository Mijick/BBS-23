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

// MARK: - Signature Generation
extension BBSTests {
    func testSignatureGeneration_1() throws {
        let message = "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation(),
            secretKey = "60e55110f76883a13d030b2f6bd11883422d5abde717569fc0731f51237169fc".asHexToByteRepresentation().toInteger(),
            publicKey = "a820f230f6ae38503b86c70dc50b61c58a77e45c39ab25c0652bbaa8fa136f2851bd4781c9dcde39fc9d1d52c9e60268061e7d7632171d91aa8d460acee0e96f1e7c4cfb12d3ff9ab5d5dc91c277db75c845d649ef3c4f63aebc364cd55ded0c".asHexToByteRepresentation(),
            header = "11223344556677889900aabbccddeeff".asHexToByteRepresentation()

        let signature = try bbs.generateSignature(secretKey: secretKey, publicKey: publicKey, header: header, messages: [message])
        let expectedSignature = "88c0eb3bc1d97610c3a66d8a3a73f260f95a3028bccf7fff7d9851e2acd9f3f32fdf58a5b34d12df8177adf37aa318a20f72be7d37a8e8d8441d1bc0bc75543c681bf061ce7e7f6091fe78c1cb8af103".asHexToByteRepresentation()

        XCTAssertEqual(signature, expectedSignature)
    }
}

// MARK: - Proof Generation
extension BBSTests {
    func testProofGeneration_1() throws {
        let message = "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation(),
            publicKey = "a820f230f6ae38503b86c70dc50b61c58a77e45c39ab25c0652bbaa8fa136f2851bd4781c9dcde39fc9d1d52c9e60268061e7d7632171d91aa8d460acee0e96f1e7c4cfb12d3ff9ab5d5dc91c277db75c845d649ef3c4f63aebc364cd55ded0c".asHexToByteRepresentation(),
            signature = "88c0eb3bc1d97610c3a66d8a3a73f260f95a3028bccf7fff7d9851e2acd9f3f32fdf58a5b34d12df8177adf37aa318a20f72be7d37a8e8d8441d1bc0bc75543c681bf061ce7e7f6091fe78c1cb8af103".asHexToByteRepresentation(),
            header = "11223344556677889900aabbccddeeff".asHexToByteRepresentation(),
            presentationHeader = "bed231d880675ed101ead304512e043ade9958dd0241ea70b4b3957fba941501".asHexToByteRepresentation(),
            revealedIndexes = [0]

        let proof = try bbs.generateProof(publicKey: publicKey, signature: signature, header: header, presentationHeader: presentationHeader, messages: [message], disclosedIndexes: revealedIndexes)
        let expectedProof = "a7c217109e29ecab846691eaad757beb8cc93356daf889856d310af5fc5587ea4f8b70b0d960c68b7aefa62cae806baa8edeca19ca3dd884fb977fc43d946dc2a0be8778ec9ff7a1dae2b49c1b5d75d775ba37652ae759b9bb70ba484c74c8b2aeea5597befbb651827b5eed5a66f1a959bb46cfd5ca1a817a14475960f69b32c54db7587b5ee3ab665fbd37b506830a0fdc9a7f71072daabd4cdb49038f5c55e84623400d5f78043a18f76b272fd65667373702763570c8a2f7c837574f6c6c7d9619b0834303c0f55b2314cec804b33833c7047865587b8e55619123183f832021dd97439f324fa3ad90ec45417070067fb8c56b2af454562358b1509632f92f2116c020fe7de1ba242effdb36e980".asHexToByteRepresentation()

        XCTAssertEqual(proof, expectedProof)
    }
}

// MARK: - Helpers
private extension BBSTests {
    var bbs: BBS { .init(Cipher.BLS12_381_SHA_256()) }
}
