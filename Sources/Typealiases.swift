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

typealias ProofInitVector = (Abar: CurvePoint<Fq1>, Bbar: CurvePoint<Fq1>, D: CurvePoint<Fq1>, T1: CurvePoint<Fq1>, T2: CurvePoint<Fq1>, domain: BInt)
typealias Proof = (Abar: CurvePoint<Fq1>, Bbar: CurvePoint<Fq1>, D: CurvePoint<Fq1>, e: BInt, r1: BInt, r3: BInt, m: [BInt], challenge: BInt)
typealias Signature = (A: CurvePoint<Fq1>, e: BInt)
