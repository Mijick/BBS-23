//
//  Ciphersuite.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

protocol Ciphersuite {
    
    // MARK: Attributes
    var id: String { get }
    var octetScalarLength: Int { get }
    var octetPointLength: Int { get }
    var expandLength: Int { get }
    var p1: BInt { get }
    var primeOrder: BInt { get }
    var curve: C { get }

    // MARK: Methods
    func pointToOctets(_ point: [UInt8]) -> [UInt8]
    func octetsToPoint(_ bytes: [UInt8]) -> [UInt8]

    // MARK: - Generic Types
    associatedtype C: CurveSuite
}
