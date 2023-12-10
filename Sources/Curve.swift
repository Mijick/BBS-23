//
//  Curve.swift of BBS-Signature
//
//  Created by Tomasz Kurylik
//    - Twitter: https://twitter.com/tkurylik
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//
//  Copyright ©2023 Mijick. Licensed under MIT License.


import BigInt

enum Curve {}
protocol CurveSuite {
    // MARK: Attributes

    /// Domain separation tag for a curve
    var dst: String { get }

    /// Basic curve defined by: y^2 = x^3 + Ax + B
    var A: BInt { get }

    /// Basic curve defined by: y^2 = x^3 + Ax + B
    var B: ComplexValue { get }

    /// Characteristic of the field F
    var p: BInt { get }

    /// Order of G1 and G2
    var r: BInt { get }

    /// Extension degree of the field F
    var m: Int { get }

    /// Length parameter for hashToField method
    var L: Int { get }

    /// A non-zero element of F
    var Z: BInt { get }

    /// Scalar parameter for clearCofactor method
    var hEff: BInt { get }

    /// Input block size of hashData, measured in byte. For example, for SHA-256, size = 64
    var hashOutputSizeInBytes: Int { get }


    // MARK: Methods

    /// Returns the canonical representation of the point P for the selected subgroup
    func serializePoint(_ point: CurvePoint) throws -> [UInt8]

    /// Returns the point P in the subgroup corresponding to the canonical representation
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint

    /// Calculates a point on the elliptic curve E from an element of the finite field F over which E is defined
    func mapToCurve(_ u: BInt) -> CurvePoint

    /// Expands a byte string and domain separation tag into a uniformly random byte string
    func expandMessage(_ messageBytes: [UInt8], domainSeparationTag: [UInt8], expectedLengthInBytes: Int) throws -> [UInt8]

    /// Hashes bytes
    func hashData(_ bytes: [UInt8]) -> [UInt8]
}

// MARK: - Helpers
extension CurveSuite {
    /// Encodes a byte string to a point in G
    func hashToCurve(_ bytes: [UInt8]) throws -> CurvePoint {
        let fieldElements = try hashToField(bytes, 2)

        let point1 = mapToCurve(fieldElements[0])
        let point2 = mapToCurve(fieldElements[1])

        let point3 = point1 + point2
        let resultPoint = clearCofactor(point3)
        return resultPoint
    }

    /// Function that defines the curve
    func f(_ x: ComplexValue) -> ComplexValue { x * x * x + A * x + B }
}
private extension CurveSuite {
    /// Hashes arbitrary-length byte strings to a list of one or more elements of a finite field F
    func hashToField(_ bytes: [UInt8], _ count: Int) throws -> [BInt] {
        let uniformBytes = try createUniformBytesArray(bytes, count)
        
        let listOfElements = createListOfElements(uniformBytes, count)
        return .init(listOfElements.joined())
    }

    /// Sends any point on the curve E to the subgroup G of E
    func clearCofactor(_ point: CurvePoint) -> CurvePoint { point * hEff }
}

// MARK: - Hash to Field Helpers
private extension CurveSuite {
    func createUniformBytesArray(_ bytes: [UInt8], _ count: Int) throws -> [UInt8] { try expandMessage(
        bytes,
        domainSeparationTag: dst.asAsciiToByteRepresentation(),
        expectedLengthInBytes: count * m * L
    )}
    func createListOfElements(_ uniformBytes: [UInt8], _ count: Int) -> [[BInt]] {
        var listOfElements: [[BInt]] = []

        for i in 0..<count {
            var tempArray: [BInt] = []

            for j in 0..<m {
                let elementOffset = L * (j + i * m)
                let temp = Array(uniformBytes[elementOffset..<elementOffset + L])
                let element = Primitives.bytesToInteger(temp) % p

                tempArray.append(element)
            }

            listOfElements.append(tempArray)
        }

        return listOfElements
    }
}
