//
//  PrimitivesTests.swift of BBS-Signature
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

final class PrimitivesTests: XCTestCase {}

// MARK: - Integer to Bytes Tests
extension PrimitivesTests {
    func test_I20SP_error_negativeExpectedLength() {
        XCTAssertThrowsError(try Primitives.integerToBytes(value: 255, expectedLength: -1)) { error in
            let error = error as! PrimitivesError.I20SP
            XCTAssertEqual(error, .negativeExpectedLength)
        }
    }
    func test_I20SP_error_tooLargeInteger() {
        XCTAssertThrowsError(try Primitives.integerToBytes(value: 1000, expectedLength: 1)) { error in
            let error = error as! PrimitivesError.I20SP
            XCTAssertEqual(error, .tooLargeInteger)
        }
    }
    func test_I20SP_1() throws {
        let value = try Primitives.integerToBytes(value: 255, expectedLength: 1)
        let expectedValue: [UInt8] = [255]
        XCTAssertEqual(value, expectedValue)
    }
    func test_I20SP_2() throws {
        let value = try Primitives.integerToBytes(value: 257, expectedLength: 2)
        let expectedValue: [UInt8] = [1, 1]
        XCTAssertEqual(value, expectedValue)
    }
    func test_I20SP_3() throws {
        let value = try Primitives.integerToBytes(value: 23, expectedLength: 4)
        let expectedValue: [UInt8] = [0, 0, 0, 23]
        XCTAssertEqual(value, expectedValue)
    }
    func test_I20SP_4() throws {
        let value = try Primitives.integerToBytes(value: 1241, expectedLength: 6)
        let expectedValue: [UInt8] = [0, 0, 0, 0, 4, 217]
        XCTAssertEqual(value, expectedValue)
    }
    func test_I20SP_5() throws {
        let value = try Primitives.integerToBytes(value: 1024531, expectedLength: 8)
        let expectedValue: [UInt8] = [0, 0, 0, 0, 0, 15, 162, 19]
        XCTAssertEqual(value, expectedValue)
    }
}

// MARK: - Bytes to Integer Tests
extension PrimitivesTests {
    func test_OS2IP_1() {
        let value = Primitives.bytesToInteger([255])
        let expectedValue: BigUInt = 255
        XCTAssertEqual(value, expectedValue)
    }
    func test_OS2IP_2() {
        let value = Primitives.bytesToInteger([1, 1])
        let expectedValue: BigUInt = 257
        XCTAssertEqual(value, expectedValue)
    }
    func test_OS2IP_3() {
        let value = Primitives.bytesToInteger([0, 0, 0, 23])
        let expectedValue: BigUInt = 23
        XCTAssertEqual(value, expectedValue)
    }
    func test_OS2IP_4() {
        let value = Primitives.bytesToInteger([0, 0, 4, 217])
        let expectedValue: BigUInt = 1241
        XCTAssertEqual(value, expectedValue)
    }
    func test_OS2IP_5() {
        let value = Primitives.bytesToInteger([0, 0, 0, 0, 0, 15, 162, 19])
        let expectedValue: BigUInt = 1024531
        XCTAssertEqual(value, expectedValue)
    }
}
