//
//  Hash.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

enum Hash {}
protocol HashType {
    // MARK: Attributes

    /// Output size of hashData in bits. For example, for SHA-256 = 256, size = 32
    var bInBytes: Int { get }

    /// Input block size of hashData, measured in byte. For example, for SHA-256, size = 64
    var sInBytes: Int { get }


    // MARK: Methods
    
    /// Hashes bytes
    func hashData(_ bytes: [UInt8]) -> [UInt8]
}
