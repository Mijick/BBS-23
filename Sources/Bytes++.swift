//
//  Bytes++.swift of
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation
import BigInt

// MARK: - Operations
extension [UInt8] {
    func xor(_ key: [UInt8]) -> [UInt8] {
        var array = self
        for i in 0..<count { array[i] ^= key[i % key.count] }
        return array
    }
    func and(_ key: [UInt8]) -> [UInt8] {
        var array = self
        for i in 0..<count { array[i] &= key[i % key.count] }
        return array
    }
    func or(_ key: [UInt8]) -> [UInt8] {
        var array = self
        for i in 0..<count { array[i] |= key[i % key.count] }
        return array
    }
    func concatenate(with bytes: [UInt8]) -> [UInt8] {
        let data1 = Data(self), data2 = Data(bytes)

        let mutableData = NSMutableData()
        mutableData.append(data1)
        mutableData.append(data2)
        return .init(mutableData)
    }
}

// MARK: - Converting to Hex
extension [UInt8] {
    func toHexRepresentation() -> String {
        var hexString: String = ""
        for byte in self { hexString.append(String(format:"%02X", byte)) }
        return hexString.lowercased()
    }
}

// MARK: - Bytes to Integer
extension [UInt8] {
    func toInteger() -> BInt { Primitives.bytesToInteger(self) }
}

// MARK: - Random Bytes
extension [UInt8] {
    static func random(length: Int) -> [UInt8]? {
        var bytes = [UInt8](repeating: 0, count: length)
        switch SecRandomCopyBytes(kSecRandomDefault, length, &bytes) {
            case errSecSuccess: return bytes
            default: return nil
        }
    }
}
