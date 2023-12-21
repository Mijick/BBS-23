//
//  Cipher.BLS12_381_SHA_256.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

extension Cipher { struct BLS12_381_SHA_256: CipherSuite {
    let id: String = "BBS_BLS12381G1_XMD:SHA-256_SSWU_RO_"
    let octetScalarLength: Int = 32
    let octetPointLength: Int = 48
    let expandLength: Int = 48
    let hash: HashType = Hash.SHA256()
    let p1: CurvePoint
    let curveG1: CurveSuite
    let curveG2: CurveSuite
    let expandMessage: MessageExpander

    init() {
        self.expandMessage = ExpandMessage.XMD(hasher: hash)
        self.curveG1 = Curve.BLS12_381_G1(expandMessage: expandMessage)
        self.curveG2 = Curve.BLS12_381_G2(expandMessage: expandMessage)
        self.p1 = try! curveG1.deserializePoint("a8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9".asHexToByteRepresentation())
    }
}}
