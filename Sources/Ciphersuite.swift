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
    var p1: Int { get }

    // MARK: Methods
    func expandMessage(message: [UInt8], dst: [UInt8], lengthInBytes: Int) -> [UInt8]
    func pointToOctets_g1()
    func pointToOctets_g2()
    func octetsToPoint_g1()
    func octetsToPoint_g2()

    func hashData(_ data: Data) -> Data
}
