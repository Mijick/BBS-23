//
//  UtilitiesTest.swift of BBS-Signature
//
//  Created by Alina Petrovska on 30.11.2023.
//    - Mail: alina.petrovskaya@mijick.com
//    - GitHub: https://github.com/Mijick
//
//  Copyright ©2023 Mijick. Licensed under MIT License.

import Foundation

import XCTest
import BigInt
@testable import MijickBBS_Signature

final class UtilitiesTest: XCTestCase {}

// MARK: - Creating Generators
extension UtilitiesTest {
    func testCreateGenerators() throws {
        let results = try utilities
            .createGenerators(count: 11, apiID: apiID)
            .map { try utilities.serialize(input: [$0]) }

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
        XCTAssertEqual(results.first!, expectedResults.first!)
    }
}
private extension UtilitiesTest {
    
}

// MARK: - Hash to Scalar
extension UtilitiesTest {
    func test_hashToScalar() throws {
        let msg = "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation()

        let result = try utilities.hashToScalar(msg, dst)
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
        let result = try? utilities.messagesToScalars(messages: [m_1], apiID: apiID)
        let expectedResult: [BInt] = ["1cb5bb86114b34dc438a911617655a1db595abafac92f47c5001799cf624b430"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar2() {
        let result = try? utilities.messagesToScalars(messages: [m_2], apiID: apiID)
        let expectedResult: [BInt] = ["154249d503c093ac2df516d4bb88b510d54fd97e8d7121aede420a25d9521952"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar3() {
        let result = try? utilities.messagesToScalars(messages: [m_4], apiID: apiID)
        let expectedResult: [BInt] = ["4a196deafee5c23f630156ae13be3e46e53b7e39094d22877b8cba7f14640888"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar4() {
        let result = try? utilities.messagesToScalars(messages: [m_4], apiID: apiID)
        let expectedResult: [BInt] = ["4a196deafee5c23f630156ae13be3e46e53b7e39094d22877b8cba7f14640888"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar5() {
        let result = try? utilities.messagesToScalars(messages: [m_5], apiID: apiID)
        let expectedResult: [BInt] = ["34c5ea4f2ba49117015a02c711bb173c11b06b3f1571b88a2952b93d0ed4cf7e"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar6() {
        let result = try? utilities.messagesToScalars(messages: [m_6], apiID: apiID)
        let expectedResult: [BInt] = ["4045b39b83055cd57a4d0203e1660800fabe434004dbdc8730c21ce3f0048b08"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar7() {
        let result = try? utilities.messagesToScalars(messages: [m_7], apiID: apiID)
        let expectedResult: [BInt] = ["64621da4377b6b1d05ecc37cf3b9dfc94b9498d7013dc5c4a82bf3bb1750743"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar8() {
        let result = try? utilities.messagesToScalars(messages: [m_8], apiID: apiID)
        let expectedResult: [BInt] = ["34ac9196ace0a37e147e32319ea9b3d8cc7d21870d3c3ba071246859cca49b02"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar9() {
        let result = try? utilities.messagesToScalars(messages: [m_9], apiID: apiID)
        let expectedResult: [BInt] = ["57eb93f417c43200e9784fa5ea5a59168d3dbc38df707a13bb597c871b2a5f74"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar10() {
        let result = try? utilities.messagesToScalars(messages: [m_10], apiID: apiID)
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
        let point = CurvePoint(
            x: .init(decimal: "1031246738451272257918307649645427926126395098676218623157461618035668551328720548531524570871230389539697713933182"),
            y: .init(decimal: "3770865391344759460897441956007821360607472141384078872418818486419925991873542360161539566057289824728296659129050"),
            utilities.ciphersuite.curveG1
        )
        let scalar = BInt(hex: "1004262112c3eaa95941b2b0d1311c09c845db0099a50e67eda628ad26b43083")
        let signature = (point: point, scalar: scalar)

        let signatureOctets = try utilities.signatureToOctets(signature: signature)
        let octetsSignature = try utilities.octetsToSignature(signatureOctets: signatureOctets)

        XCTAssertEqual(signature.point, octetsSignature.point)
        XCTAssertEqual(signature.scalar, octetsSignature.scalar)
    }
}


// MARK: - Helpers
private extension UtilitiesTest {
    var utilities: Utilities { .init(Cipher.BLS12_381_SHA_256()) }
}
