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

// MARK: - Hasing to Curve
extension BLS12_381_G2_Tests {
    func test_hashToCurve_1() {
        let bytes = "".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            xComplex: [.init(decimal: "1621169081573085681239791067342887223798336929756494122922080106020517223143455671595781382068418043280544215228327"), .init(decimal: "1587587486146751690902193817105810639863689020339711120960195972042040056930190472657387432543142596013791096481490")],
            yComplex: [.init(decimal: "970966172969753563835279261935645107175810389630330309589294521125466412550049106270842945181812158581216178908978"), .init(decimal: "2604343480472196888590735567210713355767675214828829116243510142820626223172675708232496834944806825075739059590827")],
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hasToCurve_2() {
        let bytes = "paranoid".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            xComplex: [.init(decimal: "2065177827200864054063283115581631338843026042947039488144919478653840152503764494249006136403186444241787268769743"), .init(decimal: "2230032963471253692963565667910385507411002966367028284166525282418579954985077407946033992683098137793330100407609")],
            yComplex: [.init(decimal: "1230996140740745892628791918655993424306871313716621610901530782178128654352293520035936687389684912873467888829618"), .init(decimal: "1360522819366389159502382397685049599082099085874052585763512518157213579337246755277321160328722508815766656483344")],
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hasToCurve_3() {
        let bytes = "generalnietouwazamzemarchewzmieszanazpasternakiemjestsurowkawykazujacazbytduzywplywnapoziomglukozywekrwiwzwiazkuzczymnienalezyichmieszacrazem".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            xComplex: [.init(decimal: "3251616667347943653766421878724854354871594854588624528398976702855363849364879855673440846962932573728071782911255"), .init(decimal: "349966527168332972855616747738354862706552449657746311797787593150986262332696905040578361593738017178811952356950")],
            yComplex: [.init(decimal: "3166048891970127248587504664104068120173322450621310432802914331089423128517321736207545326062071970271856311490713"), .init(decimal: "2355741065523296924636086002708944069557796852734426130386996965146977013982251536739932329478686109253462283066581")],
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
}

// MARK: - Helpers
private extension BLS12_381_G2_Tests {
    var curve: CurveSuite { Curve.BLS12_381_G2() }
}
