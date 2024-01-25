//
//  Cipher.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

enum Cipher {}
protocol CipherSuite {
    /// Identifier of the ciphersuite
    var id: String { get }

    /// The length of a scalar octet representation
    var octetScalarLength: Int { get }

    /// The length of a point in G1 octet representation
    var octetPointLength: Int { get }

    /// The length of message expander
    var expandLength: Int { get }

    /// Characteristic of the field F
    var p: BInt { get }

    /// Order of G1 and G2
    var r: BInt { get }

    /// Fixed point of G1
    var p1: Point<Fq1> { get }

    /// Defined by the suite specified by the hash to curve suite parameter of the ciphersuite
    var expandMessage: MessageExpander { get }

    /// The curve for G1
    var curveG1: any CurveSuite<Fq1> { get }

    /// The curve for G2
    var curveG2: any CurveSuite<Fq2> { get }
}
