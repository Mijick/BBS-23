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

// MARK: - Hash to scalar
final class UtilitiesTest: XCTestCase {}
    
extension UtilitiesTest {
    func test_hashToScalars() {
        let ciphersuite = BLS12_381_SHA_256()
        let msg = "9872ad089e452c7b6e283dfac2a80d58e8d0ff71cc4d5e310a1debdda4a45f02".asHexToByteRepresentation()
        let dst = ciphersuite.dst.asAsciiToByteRepresentation()
        
        let result = try? Utilities.hashToScalar(msg, dst, ciphersuite).toHexString()
        let expectedResult = "0f90cbee27beb214e6545becb8404640d3612da5d6758dffeccd77ed7169807c"
        XCTAssertEqual(result, expectedResult)
    }
}
