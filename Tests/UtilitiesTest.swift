//
//  UtilitiesTest.swift of MijickBBS23
//
//  Created by Alina Petrovska on 30.11.2023.
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/Mijick
//
//  Copyright ©2023 Mijick. Licensed under MIT License.

import Foundation

import XCTest
import BigInt
@testable import MijickBBS23

final class UtilitiesTest: XCTestCase {}

// MARK: - Creating Generators
extension UtilitiesTest {
    func testCreateGenerators() throws {
        let results = try Utilities
            .createGenerators(count: 11, apiID: apiID)
            .map { try Utilities.serialize(input: [$0]) }

        let expectedResults: [[UInt8]] = [
            "a9ec65b70a7fbe40c874c9eb041c2cb0a7af36ccec1bea48fa2ba4c2eb67ef7f9ecb17ed27d38d27cdeddff44c8137be".asHexToByteRepresentation(),
            "98cd5313283aaf5db1b3ba8611fe6070d19e605de4078c38df36019fbaad0bd28dd090fd24ed27f7f4d22d5ff5dea7d4".asHexToByteRepresentation(),
            "a31fbe20c5c135bcaa8d9fc4e4ac665cc6db0226f35e737507e803044093f37697a9d452490a970eea6f9ad6c3dcaa3a".asHexToByteRepresentation(),
            "b479263445f4d2108965a9086f9d1fdc8cde77d14a91c856769521ad3344754cc5ce90d9bc4c696dffbc9ef1d6ad1b62".asHexToByteRepresentation(),
            "ac0401766d2128d4791d922557c7b4d1ae9a9b508ce266575244a8d6f32110d7b0b7557b77604869633bb49afbe20035".asHexToByteRepresentation(),
            "b95d2898370ebc542857746a316ce32fa5151c31f9b57915e308ee9d1de7db69127d919e984ea0747f5223821b596335".asHexToByteRepresentation(),
            "8f19359ae6ee508157492c06765b7df09e2e5ad591115742f2de9c08572bb2845cbf03fd7e23b7f031ed9c7564e52f39".asHexToByteRepresentation(),
            "abc914abe2926324b2c848e8a411a2b6df18cbe7758db8644145fefb0bf0a2d558a8c9946bd35e00c69d167aadf304c1".asHexToByteRepresentation(),
            "80755b3eb0dd4249cbefd20f177cee88e0761c066b71794825c9997b551f24051c352567ba6c01e57ac75dff763eaa17".asHexToByteRepresentation(),
            "82701eb98070728e1769525e73abff1783cedc364adb20c05c897a62f2ab2927f86f118dcb7819a7b218d8f3fee4bd7f".asHexToByteRepresentation(),
            "a1f229540474f4d6f1134761b92b788128c7ac8dc9b0c52d59493132679673032ac7db3fb3d79b46b13c1c41ee495bca".asHexToByteRepresentation()
        ]
        XCTAssertEqual(results, expectedResults)
    }
}

// MARK: - Hash to Scalar
extension UtilitiesTest {
    func test_hashToScalar() throws {
        let msg = "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation()

        let result = try Utilities.hashToScalar(msg, dst)
        let expectedResult: BInt = "0f90cbee27beb214e6545becb8404640d3612da5d6758dffeccd77ed7169807c"
        XCTAssertEqual(result, expectedResult)
    }
}
private extension UtilitiesTest {
    var dst: [UInt8] { "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_H2S_".asAsciiToByteRepresentation() }
}

// MARK: - Messages to Scalar
extension UtilitiesTest {
    func test_messagesToScalar1() {
        let result = try? Utilities.messagesToScalars(messages: [m_1], apiID: apiID)
        let expectedResult: [BInt] = ["1cb5bb86114b34dc438a911617655a1db595abafac92f47c5001799cf624b430"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar2() {
        let result = try? Utilities.messagesToScalars(messages: [m_2], apiID: apiID)
        let expectedResult: [BInt] = ["154249d503c093ac2df516d4bb88b510d54fd97e8d7121aede420a25d9521952"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar3() {
        let result = try? Utilities.messagesToScalars(messages: [m_3], apiID: apiID)
        let expectedResult: [BInt] = ["0c7c4c85cdab32e6fdb0de267b16fa3212733d4e3a3f0d0f751657578b26fe22"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar4() {
        let result = try? Utilities.messagesToScalars(messages: [m_4], apiID: apiID)
        let expectedResult: [BInt] = ["4a196deafee5c23f630156ae13be3e46e53b7e39094d22877b8cba7f14640888"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar5() {
        let result = try? Utilities.messagesToScalars(messages: [m_5], apiID: apiID)
        let expectedResult: [BInt] = ["34c5ea4f2ba49117015a02c711bb173c11b06b3f1571b88a2952b93d0ed4cf7e"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar6() {
        let result = try? Utilities.messagesToScalars(messages: [m_6], apiID: apiID)
        let expectedResult: [BInt] = ["4045b39b83055cd57a4d0203e1660800fabe434004dbdc8730c21ce3f0048b08"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar7() {
        let result = try? Utilities.messagesToScalars(messages: [m_7], apiID: apiID)
        let expectedResult: [BInt] = ["64621da4377b6b1d05ecc37cf3b9dfc94b9498d7013dc5c4a82bf3bb1750743"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar8() {
        let result = try? Utilities.messagesToScalars(messages: [m_8], apiID: apiID)
        let expectedResult: [BInt] = ["34ac9196ace0a37e147e32319ea9b3d8cc7d21870d3c3ba071246859cca49b02"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar9() {
        let result = try? Utilities.messagesToScalars(messages: [m_9], apiID: apiID)
        let expectedResult: [BInt] = ["57eb93f417c43200e9784fa5ea5a59168d3dbc38df707a13bb597c871b2a5f74"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar10() {
        let result = try? Utilities.messagesToScalars(messages: [m_10], apiID: apiID)
        let expectedResult: [BInt] = ["8e3afeb2b4f2b5f907924ef42856616e6f2d5f1fb373736db1cca32707a7d16"]
        XCTAssertEqual(result, expectedResult)
    }
}
private extension UtilitiesTest {
    var m_1: [UInt8] { "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation() }
    var m_2: [UInt8] { "c344136d9ab02da4dd5908bbba913ae6f58c2cc844b802a6f811f5fb075f9b80".asHexToByteRepresentation() }
    var m_3: [UInt8] { "7372e9daa5ed31e6cd5c825eac1b855e84476a1d94932aa348e07b73".asHexToByteRepresentation() }
    var m_4: [UInt8] { "77fe97eb97a1ebe2e81e4e3597a3ee740a66e9ef2412472c".asHexToByteRepresentation() }
    var m_5: [UInt8] { "496694774c5604ab1b2544eababcf0f53278ff50".asHexToByteRepresentation() }
    var m_6: [UInt8] { "515ae153e22aae04ad16f759e07237b4".asHexToByteRepresentation() }
    var m_7: [UInt8] { "d183ddc6e2665aa4e2f088af".asHexToByteRepresentation() }
    var m_8: [UInt8] { "ac55fb33a75909ed".asHexToByteRepresentation() }
    var m_9: [UInt8] { "96012096".asHexToByteRepresentation() }
    var m_10: [UInt8] { "".asHexToByteRepresentation() }
    var apiID: [UInt8] { "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_H2G_HM2S_".asAsciiToByteRepresentation() }
}

// MARK: - Signature to Octets
extension UtilitiesTest {
    func testSignatureToOctets() throws {
        let point = Point<Fq1>(
            x: "6b33cb8414e56bdd5d7b4b8a1f07492061d54ab788eba8614dc529578876188b6396eae57e49cb75831def97c5eeb7e",
            y: "187ff356ffe7027e926f0f9e0e917e9d28898fd3eaaaa6670a60e696fad8367110cc03f19043b9c3b8482e435e1892da"
        )
        let scalar = BInt(hex: "1004262112c3eaa95941b2b0d1311c09c845db0099a50e67eda628ad26b43083")
        let signature = (A: point, e: scalar)

        let signatureOctets = try Utilities.signatureToOctets(signature: signature)
        let octetsSignature = try Utilities.octetsToSignature(signatureOctets: signatureOctets)

        XCTAssertEqual(signature.A, octetsSignature.A)
        XCTAssertEqual(signature.e, octetsSignature.e)
    }
}

// MARK: - Proof to Octets
extension UtilitiesTest {
    func testProofToOctets() throws {
        let proofOctets = "a8da259a5ae7a9a8e5e4e809b8e7718b4d7ab913ed5781ebbff4814c762033eda4539973ed9bf557f882192518318cc4916fdffc857514082915a31df5bbb79992a59fd68dc3b48d19d2b0ad26be92b4cf78a30f472c0fd1e558b9d03940b077897739228c88afc797916dca01e8f03bd9c5375c7a7c59996e514bb952a436afd24457658acbaba5ddac2e693ac481352bb6fce6084eb1867c71caeac2afc4f57f4d26504656b798b3e4009eb227c7fa41b6ae00daae0436d853e86b32b366b0a9929e1570369e9c61b7b177eb70b7ff27326c467c362120dfeacc0692d25ccdd62d733ff6e8614abd16b6b63a7b78d11632cf41bc44856aee370fee6690a637b3b1d8d8525aff01cd3555c39d04f8ee1606964c2da8b988897e3d27cb444b8394acc80876d3916c485c9f36098fed6639f12a6a6e67150a641d7485656408e9ae22b9cb7ec77e477f71c1fe78cab3ee5dd62c34dd595edb15cbce061b29192419dfadcdee179f134dd8feb9323c426c51454168ffacb65021995848e368a5c002314b508299f67d85ad0eaaaac845cb029927191152edee034194cca3ae0d45cbd2f5e5afd1f9b8a3dd903adfa17ae43a191bf3119df57214f19e662c7e01e8cc2eb6b038bc7d707f2f3e13545909e0".asHexToByteRepresentation()

        let proof = try! Utilities.octetsToProof(proofOctets: proofOctets)
        let result = try Utilities.proofToOctets(proof)

        XCTAssertEqual(proofOctets, result)
    }
}
