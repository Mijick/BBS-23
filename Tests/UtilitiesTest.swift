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
        let result = try? utilities.messagesToScalars(messages: [m_1], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["1cb5bb86114b34dc438a911617655a1db595abafac92f47c5001799cf624b430"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar2() {
        let result = try? utilities.messagesToScalars(messages: [m_2], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["154249d503c093ac2df516d4bb88b510d54fd97e8d7121aede420a25d9521952"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar3() {
        let result = try? utilities.messagesToScalars(messages: [m_4], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["4a196deafee5c23f630156ae13be3e46e53b7e39094d22877b8cba7f14640888"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar4() {
        let result = try? utilities.messagesToScalars(messages: [m_4], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["4a196deafee5c23f630156ae13be3e46e53b7e39094d22877b8cba7f14640888"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar5() {
        let result = try? utilities.messagesToScalars(messages: [m_5], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["34c5ea4f2ba49117015a02c711bb173c11b06b3f1571b88a2952b93d0ed4cf7e"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar6() {
        let result = try? utilities.messagesToScalars(messages: [m_6], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["4045b39b83055cd57a4d0203e1660800fabe434004dbdc8730c21ce3f0048b08"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar7() {
        let result = try? utilities.messagesToScalars(messages: [m_7], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["64621da4377b6b1d05ecc37cf3b9dfc94b9498d7013dc5c4a82bf3bb1750743"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar8() {
        let result = try? utilities.messagesToScalars(messages: [m_8], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["34ac9196ace0a37e147e32319ea9b3d8cc7d21870d3c3ba071246859cca49b02"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar9() {
        let result = try? utilities.messagesToScalars(messages: [m_9], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["57eb93f417c43200e9784fa5ea5a59168d3dbc38df707a13bb597c871b2a5f74"]
        XCTAssertEqual(result, expectedResult)
    }
    func test_messagesToScalar10() {
        let result = try? utilities.messagesToScalars(messages: [m_10], apiID: apiID).map { $0.asString(radix: 16, uppercase: false) }
        let expectedResult = ["8e3afeb2b4f2b5f907924ef42856616e6f2d5f1fb373736db1cca32707a7d16"]
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
