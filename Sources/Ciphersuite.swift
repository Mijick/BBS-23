//
//  Ciphersuite.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

protocol Ciphersuite {
    
    // MARK: Attributes
    var id: String { get }
    var octetScalarLength: Int { get }
    var octetPointLength: Int { get }
    var expandLength: Int { get }
    var p1: [UInt8] { get }
    var primeOrder: [UInt8] { get }
    var domainSeparationTag: String { get }

    // MARK: Methods
    func expandMessage(_ bytes: [UInt8], domainSeparationTag: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8]
    func pointToOctets_g1(_ point: [UInt8]) -> [UInt8]
    func pointToOctets_g2(_ point: [UInt8]) -> [UInt8]
    func octetsToPoint_g1(_ bytes: [UInt8]) -> [UInt8]
    func octetsToPoint_g2(_ bytes: [UInt8]) -> [UInt8]

    func hashData(_ bytes: [UInt8]) -> [UInt8]
}
