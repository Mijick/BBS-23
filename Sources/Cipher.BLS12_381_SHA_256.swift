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
    let p1: CurvePoint<Fq1> = .init(x: "8ce256102840821a3e94ea9025e4662b205762f9776b3a766c872b948f1fd225e7c59698588e70d11406d161b4e28c9", y: "10a711acd16ff43e30b3373b7b6a9233945ec74adf00b0481fbcd5e3b1e342e7a105b4966195e6a678857a0e0493d5b1")
    let curveG1: any CurveSuite<Fq1>
    let curveG2: any CurveSuite<Fq2>
    let expandMessage: MessageExpander
    let p: BInt = "1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab"
    let r: BInt = "73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001"

    init() {
        self.expandMessage = ExpandMessage.XMD(hasher: hash)
        self.curveG1 = Curve.BLS12_381_G1(expandMessage: expandMessage)
        self.curveG2 = Curve.BLS12_381_G2(expandMessage: expandMessage)
    }
}}
