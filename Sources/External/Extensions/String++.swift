//
//  String++.swift of MijickBBS23
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

// MARK: - To Byte Representation as ASCII
extension String {
    func asAsciiToByteRepresentation() -> [UInt8] { .init(self.utf8) }
}

// MARK: - To Byte Representation as HEX
extension String {
    func asHexToByteRepresentation() -> [UInt8] { 
        var start = startIndex

        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let end = index(after: start)
            defer { start = index(after: end) }
            return UInt8(self[start...end], radix: 16)
        }
    }
}
