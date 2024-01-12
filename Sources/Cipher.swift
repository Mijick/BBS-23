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
    var p1: CurvePoint<Fq1> { get }
    var curveG1: any CurveSuite<Fq1> { get }
    var curveG2: any CurveSuite<Fq2> { get }
    var expandMessage: MessageExpander { get }
}
extension CipherSuite {
    var p: BInt { curveG1.p }
    var r: BInt { curveG1.r }
}
