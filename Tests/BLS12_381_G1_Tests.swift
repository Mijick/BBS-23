//
//  BLS12_381_G1_Tests.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import XCTest
@testable import MijickBBS_Signature

final class BLS12_381_G1_Tests: XCTestCase {}

// MARK: - Point Serialization & Deserialization
extension BLS12_381_G1_Tests {
    func testSerialization_1() throws {
        let bytes = "a8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9".asHexToByteRepresentation()

        let deserializedPoint = try curve.deserializePoint(bytes)
        let serializedPoint = try curve.serializePoint(deserializedPoint)

        XCTAssertEqual(bytes, serializedPoint)
    }
    func testSerialization_2() throws {
        let point = CurvePoint(x: 0, y: nil, curve)

        let serializedPoint = try curve.serializePoint(point)
        let deserializedPoint = try curve.deserializePoint(serializedPoint)

        XCTAssertEqual(point, deserializedPoint)
    }
}

// MARK: - Hasing to Curve
extension BLS12_381_G1_Tests {
    func test_hashToCurve_1() {
        let bytes = "".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: "052926add2207b76ca4fa57a8734416c8dc95e24501772c814278700eed6d1e4e8cf62d9c09db0fac349612b759e79a1",
            y: "08ba738453bfed09cb546dbb0783dbb3a5f1f566ed67bb6be0e8c67e2e81a4cc68ee29813bb7994998f3eae0c9c6a265",
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_2() {
        let bytes = "abc".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: "03567bc5ef9c690c2ab2ecdf6a96ef1c139cc0b2f284dca0a9a7943388a49a3aee664ba5379a7655d3c68900be2f6903",
            y: "0b9c15f3fe6e5cf4211f346271d7b01c8f3b28be689c8429c85b67af215533311f0b8dfaaa154fa6b88176c229f2885d",
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_3() {
        let bytes = "abcdef0123456789".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: "11e0b079dea29a68f0383ee94fed1b940995272407e3bb916bbf268c263ddd57a6a27200a784cbc248e84f357ce82d98",
            y: "03a87ae2caf14e8ee52e51fa2ed8eefe80f02457004ba4d486d6aa1f517c0889501dc7413753f9599b099ebcbbd2d709",
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_4() {
        let bytes = "q128_qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: "15f68eaa693b95ccb85215dc65fa81038d69629f70aeee0d0f677cf22285e7bf58d7cb86eefe8f2e9bc3f8cb84fac488",
            y: "1807a1d50c29f430b8cafc4f8638dfeeadf51211e1602a5f184443076715f91bb90a48ba1e370edce6ae1062f5e6dd38",
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_5() {
        let bytes = "a512_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: "082aabae8b7dedb0e78aeb619ad3bfd9277a2f77ba7fad20ef6aabdc6c31d19ba5a6d12283553294c1825c4b3ca2dcfe",
            y: "05b84ae5a942248eea39e1d91030458c40153f3b654ab7872d779ad1e942856a20c438e8d99bc8abfbf74729ce1f7ac8",
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
}

// MARK: - Helpers
private extension BLS12_381_G1_Tests {
    var curve: CurveSuite { Cipher.BLS12_381_SHA_256().curveG1 }
}
