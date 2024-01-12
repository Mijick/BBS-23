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
protocol CurveSuite<F> {

    // MARK: Attributes

    /// Domain separation tag for a curve
    var dst: String { get }

    /// Basic curve defined by: y^2 = x^3 + Ax + B
    var A: F { get }

    /// Prime curve defined by: y^2 = x^3 + Aʹx + Bʹ
    var Aʹ: F { get }

    /// Basic curve defined by: y^2 = x^3 + Ax + B
    var B: F { get }

    /// Prime curve defined by: y^2 = x^3 + Aʹx + Bʹ
    var Bʹ: F { get }

    /// Characteristic of the field F
    var p: BInt { get }

    /// Order of G1 and G2
    var r: BInt { get }

    /// Extension degree of the field F
    var m: Int { get }

    /// Length parameter for hashToField method
    var L: Int { get }

    /// A non-zero element of F
    var Z: F { get }

    /// Scalar parameter for clearCofactor method
    var hEff: BInt { get }

    /// Contains a single function that generates a uniformly random byte string
    var expandMessage: MessageExpander { get }

    /// Constant point (X coordinate) on the G subgroup
    var BPx: F { get }

    /// Constant point (T coordinate) on the G subgroup
    var BPy: F { get }


    // MARK: Methods

    /// Returns the canonical representation of the point P for the selected subgroup
    func serializePoint(_ point: CurvePoint) throws -> [UInt8]

    /// Returns the point P in the subgroup corresponding to the canonical representation
    func deserializePoint(_ bytes: [UInt8]) throws -> CurvePoint

    /// Calculates a point on the elliptic curve E from an element of the finite field F over which E is defined
    func mapToCurve(_ u: ComplexValue) -> CurvePoint


    // MARK: Isogeny Map Values

    var xNumConstants: [ComplexValue] { get }
    var xDenConstants: [ComplexValue] { get }

    var yNumConstants: [ComplexValue] { get }
    var yDenConstants: [ComplexValue] { get }


    // MARK: Associated Types
    associatedtype F: Field
}

// MARK: - Helpers
extension CurveSuite {
    /// Encodes a byte string to a point in G
    func hashToCurve(_ bytes: [UInt8], dst: [UInt8]? = nil) throws -> CurvePoint {
        let fieldElements = try hashToField(bytes, 2, dst)

        let point1 = mapToCurve(fieldElements[0])
        let point2 = mapToCurve(fieldElements[1])

        let point3 = point1 + point2
        let resultPoint = clearCofactor(point3)
        return resultPoint
    }

    /// Takes as input a point on E' and produces as output a point on E
    func isoMap(_ point: CurvePoint) -> CurvePoint {
        // MARK: Calculating X
        let xNum = calculateNum(point.xComplex, xNumConstants), xDen = calculateDen(point.xComplex, xDenConstants)
        let x = xNum * (xDen.modInverse(p))

        // MARK: Calculating Y
        let yNum = calculateNum(point.xComplex, yNumConstants), yDen = calculateDen(point.xComplex, yDenConstants)
        let y = point.yComplex * yNum * yDen.modInverse(p)

        let point = CurvePoint(xComplex: x, yComplex: y, self)
        return point.modularized()
    }

    /// Checks whether the given y is negative. Should be used in serialization & deserialization
    func isNegative(_ y: ComplexValue?) -> Bool {
        let y = y?.imaginary ?? y?.real ?? 0
        return y.mod(p) > (p - 1) / 2
    }

    /// Returns a base point on the G subgroup
    func getBasePoint() -> CurvePoint { .init(xComplex: .init(BPx), yComplex: .init(BPy), self) }

    /// Function that defines the basic curve
    func f(_ x: F) -> F { x * x * x + A * x + B }
}
private extension CurveSuite {
    /// Hashes arbitrary-length byte strings to a list of one or more elements of a finite field F
    func hashToField(_ bytes: [UInt8], _ count: Int, _ customDst: [UInt8]?) throws -> [ComplexValue] {
        let uniformBytes = try expandMessage.make(
            bytes,
            dst: customDst ?? dst.asAsciiToByteRepresentation(),
            expectedLengthInBytes: count * m * L
        )

        let listOfElements = createListOfElements(uniformBytes, count)
        let complexValues = listOfElements.map { ComplexValue(real: $0.first!, imaginary: $0.first == $0.last ? nil : $0.last) }
        return complexValues
    }

    /// Sends any point on the curve E to the subgroup G of E
    func clearCofactor(_ point: CurvePoint) -> CurvePoint { point * hEff }
}

// MARK: - Iso Map Helpers
private extension CurveSuite {
    func calculateNum(_ x: ComplexValue, _ array: [ComplexValue]) -> ComplexValue {
        var result = ComplexValue(real: 0, imaginary: x.imaginary != nil ? 0 : nil)

        for i in 0..<array.count {
            let valueToAdd = array[i] * x.exp(BInt(i), p)
            result = (result + valueToAdd).mod(p)
        }

        return result
    }
    func calculateDen(_ x: ComplexValue, _ array: [ComplexValue]) -> ComplexValue {
        var result = ComplexValue(real: 0, imaginary: x.imaginary != nil ? 0 : nil)

        for i in 0...array.count {
            let valueToAdd = i < array.count ? array[i] * x.exp(BInt(i), p) : x.exp(BInt(i), p)
            result = (result + valueToAdd).mod(p)
        }

        return result
    }
}

// MARK: - Hash to Field Helpers
private extension CurveSuite {
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
