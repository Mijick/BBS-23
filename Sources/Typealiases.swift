//
//  Typealiases.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

typealias ProofInitVector = (Abar: Point<Fq1>, Bbar: Point<Fq1>, D: Point<Fq1>, T1: Point<Fq1>, T2: Point<Fq1>, domain: BInt)
typealias Proof = (Abar: Point<Fq1>, Bbar: Point<Fq1>, D: Point<Fq1>, e: BInt, r1: BInt, r3: BInt, m: [BInt], challenge: BInt)
typealias Signature = (A: Point<Fq1>, e: BInt)
