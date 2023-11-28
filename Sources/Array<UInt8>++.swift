//
//  Array<UInt8>++.swift of
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import Foundation

extension [UInt8] {
    func concatenate(with bytes: [UInt8]) -> [UInt8] {
        let data1 = Data(self), data2 = Data(bytes)

        let mutableData = NSMutableData()
        mutableData.append(data1)
        mutableData.append(data2)
        return .init(mutableData)
    }
}
