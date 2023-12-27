//
//  Typealiases.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

typealias ProofInitVector = (Abar: CurvePoint, Bbar: CurvePoint, D: CurvePoint, T1: CurvePoint, T2: CurvePoint, domain: BInt)
typealias Proof = (Abar: CurvePoint, Bbar: CurvePoint, D: CurvePoint, e: BInt, r1: BInt, r3: BInt, m: [BInt], challenge: BInt)
typealias Signature = (A: CurvePoint, e: BInt)
