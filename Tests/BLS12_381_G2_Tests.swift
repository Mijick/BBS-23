//
//  BLS12_381_G2_Tests.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import XCTest
@testable import MijickBBS_Signature

final class BLS12_381_G2_Tests: XCTestCase {}

// MARK: - Point Serialization & Deserialization
extension BLS12_381_G2_Tests {
    func testSerialization_1() throws {
        let bytes = "a666d31d7e6561371644eb9ca7dbcb87257d8fd84a09e38a7a491ce0bbac64a324aa26385aebc99f47432970399a2ecb0def2d4be359640e6dae6438119cbdc4f18e5e4496c68a979473a72b72d3badf98464412e9d8f8d2ea9b31953bb24899".asHexToByteRepresentation()

        let deserializedPoint = try curve.deserializePoint(bytes)
        let serializedPoint = try curve.serializePoint(deserializedPoint)

        XCTAssertEqual(bytes, serializedPoint)
    }
}

// MARK: - Helpers
private extension BLS12_381_G2_Tests {
    var curve: CurveSuite { Curve.BLS12_381_G2() }
}
