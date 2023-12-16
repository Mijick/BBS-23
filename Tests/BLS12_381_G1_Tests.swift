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
        let bytes = "b301803f8b5ac4a1133581fc676dfedc60d891dd5fa99028805e5ea5b08d3491af75d0707adab3b70c1a6a580217bf85".asHexToByteRepresentation()

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
            x: .init(decimal: "1313210275672700111308352674601622299567967208952874617848198534618033373180005948258080857613483172152669619450156"),
            y: .init(decimal: "1083295271268767428731160781525866738409174349759914625290950147650093304199984227500696625519803933645046968350465"),
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_2() {
        let bytes = "dupa".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: .init(decimal: "1884843941653414368475955735510076771473193597258793412200662461796743345834930586634187508555411875536978671276600"),
            y: .init(decimal: "3998133779577042359401839916139720389094479906177237041387130170803842993385608109169962552208130318543665366561446"), 
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_3() {
        let bytes = "dupaichuj".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: .init(decimal: "2525244196980909815712533457285123938921364526079561686444557145011031873224548838424004128145853527915858555276581"),
            y: .init(decimal: "213293326143961106857610083006051487007518626645100171231620727374803828316356460366221539157100528096126317723530"),
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_4() {
        let bytes = "okurwamac".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: .init(decimal: "1031246738451272257918307649645427926126395098676218623157461618035668551328720548531524570871230389539697713933182"),
            y: .init(decimal: "3770865391344759460897441956007821360607472141384078872418818486419925991873542360161539566057289824728296659129050"),
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_5() {
        let bytes = "pieczenie piernikow przez Torunian powinno byc zakazane przez prawo miedzynarodowe.".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: .init(decimal: "1278083421294808417487381979194215394741441131170149498603963275091933404422884520940122971643343165438916416339897"),
            y: .init(decimal: "3924986838989227302927496476314937392988475931350994455553380556641394682120529136588994367413427051617110065728651"),
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
    func test_hashToCurve_6() {
        let bytes = "dawaj maniek, to sie kameruje. no kurwa rzeczywiscie. o jak boli, o jak boli 2".asAsciiToByteRepresentation()
        let result = try! curve.hashToCurve(bytes)

        let expectedResult = CurvePoint(
            x: .init(decimal: "744343983355628319577143793596632634444111008816928581411055010232077762116075746203334616964647403685472939637088"),
            y: .init(decimal: "502955259366278838524493247094988415363442630696454663206096420715703405237497499290174785888582595912514953000301"),
            curve
        )
        XCTAssertEqual(result, expectedResult)
    }
}

// MARK: - Helpers
private extension BLS12_381_G1_Tests {
    var curve: CurveSuite { Cipher.BLS12_381_SHA_256().curveG1 }
}
