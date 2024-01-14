//
//  Cipher.swift of BBS-Signature
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
    // MARK: Attributes
    var id: String { get }
    var octetScalarLength: Int { get }
    var octetPointLength: Int { get }
    var expandLength: Int { get }
    var hash: HashType { get }
    var curveG1: any CurveSuite<Fq1> { get }
    var curveG2: any CurveSuite<Fq2> { get }
    var expandMessage: MessageExpander { get }

    /// Characteristic of the field F
    var p: BInt { get }

    /// Order of G1 and G2
    var r: BInt { get }

    var p1: CurvePoint<Fq1> { get }
}
