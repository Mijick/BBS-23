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
import BigInt
@testable import MijickBBS_Signature

final class BBSTests: XCTestCase {}

// MARK: - Secret Key Creation
extension BBSTests {
    func testSecretKeyCreation_1() throws {
        let keyMaterial = "746869732d49532d6a7573742d616e2d546573742d494b4d2d746f2d67656e65726174652d246528724074232d6b6579".asHexToByteRepresentation()
        let keyInfo = "746869732d49532d736f6d652d6b65792d6d657461646174612d746f2d62652d757365642d696e2d746573742d6b65792d67656e".asHexToByteRepresentation()

        let generatedSecretKey = try bbs.generateSecretKey(keyMaterial: keyMaterial, keyInfo: keyInfo)
        let expectedSecretKey = secretKey

        XCTAssertEqual(generatedSecretKey, expectedSecretKey)
    }
}

// MARK: - Public Key Creation
extension BBSTests {
    func testPublicKeyCreation_1() throws {
        let generatedPublicKey = try bbs.generatePublicKey(secretKey)
        let expectedPublicKey = publicKey

        XCTAssertEqual(generatedPublicKey, expectedPublicKey)
    }
}

// MARK: - Signature Generation
extension BBSTests {
    func testSignatureGeneration_1() throws {
        let messages = [messages[0]]

        let signature = try bbs.generateSignature(secretKey: secretKey, publicKey: publicKey, header: header, messages: messages)
        let expectedSignature = signatures[0]

        XCTAssertEqual(signature, expectedSignature)
    }
    func testSignatureGeneration_2() throws {
        let signature = try bbs.generateSignature(secretKey: secretKey, publicKey: publicKey, header: header, messages: messages)
        let expectedSignature = signatures[1]

        XCTAssertEqual(signature, expectedSignature)
    }
}

// MARK: - Proof Generation
extension BBSTests {
    func testProofGeneration_1() throws {
        let messages = [messages[0]], revealedIndexes = [0], signature = signatures[0]

        let proof = try bbs.generateProof(publicKey: publicKey, signature: signature, header: header, presentationHeader: presentationHeader, messages: messages, disclosedIndexes: revealedIndexes, mocked: true)
        let expectedProof = "a7c217109e29ecab846691eaad757beb8cc93356daf889856d310af5fc5587ea4f8b70b0d960c68b7aefa62cae806baa8edeca19ca3dd884fb977fc43d946dc2a0be8778ec9ff7a1dae2b49c1b5d75d775ba37652ae759b9bb70ba484c74c8b2aeea5597befbb651827b5eed5a66f1a959bb46cfd5ca1a817a14475960f69b32c54db7587b5ee3ab665fbd37b506830a0fdc9a7f71072daabd4cdb49038f5c55e84623400d5f78043a18f76b272fd65667373702763570c8a2f7c837574f6c6c7d9619b0834303c0f55b2314cec804b33833c7047865587b8e55619123183f832021dd97439f324fa3ad90ec45417070067fb8c56b2af454562358b1509632f92f2116c020fe7de1ba242effdb36e980".asHexToByteRepresentation()

        XCTAssertEqual(proof, expectedProof)
    }
    func testProofGeneration_2() throws {
        let revealedIndexes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], signature = signatures[1]

        let proof = try bbs.generateProof(publicKey: publicKey, signature: signature, header: header, presentationHeader: presentationHeader, messages: messages, disclosedIndexes: revealedIndexes, mocked: true)
        let expectedProof = "a6faacf33f935d1910f21b1bbe380adcd2de006773896a5bd2afce31a13874298f92e602a4d35aef5880786cffc5aaf08978484f303d0c85ce657f463b71905ee7c3c0c9038671d8fb925525f623745dc825b14fc50477f3de79ce8d915d841ba73c8c97264177a76c4a03341956d2ae45ed3438ce598d5cda4f1bf9507fecef47855480b7b30b5e4052c92a4360110c322b4cb2d9796ff2d741979226249dc14d4b1fd5ca1a8f6fdfc16f726fc7683e3605d5ec28d331111a22ed81729cbb3c8c3732c7593e445f802fc3169c26857622ed31bc058fdfe68d25f0c3b9615279719c64048ea9cdb74104b27757c2d01035507d39667d77d990ec5bda22c866fcc9fe70bb5b7826a2b4e861b6b8124fbd".asHexToByteRepresentation()

        XCTAssertEqual(proof, expectedProof)
    }
    func testProofGeneration_3() throws {
        let revealedIndexes = [0, 2, 4, 6], signature = signatures[1]

        let proof = try bbs.generateProof(publicKey: publicKey, signature: signature, header: header, presentationHeader: presentationHeader, messages: messages, disclosedIndexes: revealedIndexes, mocked: true)
        let expectedProof = "a8da259a5ae7a9a8e5e4e809b8e7718b4d7ab913ed5781ebbff4814c762033eda4539973ed9bf557f882192518318cc4916fdffc857514082915a31df5bbb79992a59fd68dc3b48d19d2b0ad26be92b4cf78a30f472c0fd1e558b9d03940b077897739228c88afc797916dca01e8f03bd9c5375c7a7c59996e514bb952a436afd24457658acbaba5ddac2e693ac481352bb6fce6084eb1867c71caeac2afc4f57f4d26504656b798b3e4009eb227c7fa41b6ae00daae0436d853e86b32b366b0a9929e1570369e9c61b7b177eb70b7ff27326c467c362120dfeacc0692d25ccdd62d733ff6e8614abd16b6b63a7b78d11632cf41bc44856aee370fee6690a637b3b1d8d8525aff01cd3555c39d04f8ee1606964c2da8b988897e3d27cb444b8394acc80876d3916c485c9f36098fed6639f12a6a6e67150a641d7485656408e9ae22b9cb7ec77e477f71c1fe78cab3ee5dd62c34dd595edb15cbce061b29192419dfadcdee179f134dd8feb9323c426c51454168ffacb65021995848e368a5c002314b508299f67d85ad0eaaaac845cb029927191152edee034194cca3ae0d45cbd2f5e5afd1f9b8a3dd903adfa17ae43a191bf3119df57214f19e662c7e01e8cc2eb6b038bc7d707f2f3e13545909e0".asHexToByteRepresentation()

        XCTAssertEqual(proof, expectedProof)
    }
}

// MARK: - Helpers
private extension BBSTests {
    var secretKey: BInt { "60e55110f76883a13d030b2f6bd11883422d5abde717569fc0731f51237169fc" }
    var publicKey: [UInt8] { "a820f230f6ae38503b86c70dc50b61c58a77e45c39ab25c0652bbaa8fa136f2851bd4781c9dcde39fc9d1d52c9e60268061e7d7632171d91aa8d460acee0e96f1e7c4cfb12d3ff9ab5d5dc91c277db75c845d649ef3c4f63aebc364cd55ded0c".asHexToByteRepresentation() }
    var signatures: [[UInt8]] {[
        "88c0eb3bc1d97610c3a66d8a3a73f260f95a3028bccf7fff7d9851e2acd9f3f32fdf58a5b34d12df8177adf37aa318a20f72be7d37a8e8d8441d1bc0bc75543c681bf061ce7e7f6091fe78c1cb8af103".asHexToByteRepresentation(),
        "895cd9c0ccb9aca4de913218655346d718711472f2bf1f3e68916de106a0d93cf2f47200819b45920bbda541db2d91480665df253fedab2843055bdc02535d83baddbbb2803ec3808e074f71f199751e".asHexToByteRepresentation()
    ]}
    var header: [UInt8] { "11223344556677889900aabbccddeeff".asHexToByteRepresentation() }
    var presentationHeader: [UInt8] { "bed231d880675ed101ead304512e043ade9958dd0241ea70b4b3957fba941501".asHexToByteRepresentation() }
    var messages: [[UInt8]] {[
        "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation(),
        "c344136d9ab02da4dd5908bbba913ae6f58c2cc844b802a6f811f5fb075f9b80".asHexToByteRepresentation(),
        "7372e9daa5ed31e6cd5c825eac1b855e84476a1d94932aa348e07b73".asHexToByteRepresentation(),
        "77fe97eb97a1ebe2e81e4e3597a3ee740a66e9ef2412472c".asHexToByteRepresentation(),
        "496694774c5604ab1b2544eababcf0f53278ff50".asHexToByteRepresentation(),
        "515ae153e22aae04ad16f759e07237b4".asHexToByteRepresentation(),
        "d183ddc6e2665aa4e2f088af".asHexToByteRepresentation(),
        "ac55fb33a75909ed".asHexToByteRepresentation(),
        "96012096".asHexToByteRepresentation(),
        "".asHexToByteRepresentation()
    ]}
}
private extension BBSTests {
    var bbs: BBS { .init(Cipher.BLS12_381_SHA_256()) }
}
