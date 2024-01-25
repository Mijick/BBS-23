//
//  ExpandMessage.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

enum ExpandMessage {}
public protocol MessageExpander {
    // MARK: Attributes
    var hasher: HashType { get }

    // MARK: Methods
    func make(_ messageBytes: [UInt8], dst: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8]
}
