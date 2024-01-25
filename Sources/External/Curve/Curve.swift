//
//  Curve.swift of MijickBBS23
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
    func serializePoint(_ point: Point<F>) throws -> [UInt8]

    /// Returns the point P in the subgroup corresponding to the canonical representation
    func deserializePoint(_ bytes: [UInt8]) throws -> Point<F>

    /// Calculates a point on the elliptic curve E from an element of the finite field F over which E is defined
    func mapToCurve(_ u: F) -> Point<F>


    // MARK: Isogeny Map Values

    var xNumConstants: [F] { get }
    var xDenConstants: [F] { get }

    var yNumConstants: [F] { get }
    var yDenConstants: [F] { get }


    // MARK: Associated Types

    associatedtype F: Field
}

// MARK: - Helpers
extension CurveSuite {
    /// Encodes a byte string to a point in G
    func hashToCurve(_ bytes: [UInt8], dst: [UInt8]? = nil) throws -> Point<F> {
        let fieldElements = try hashToField(bytes, 2, dst)

        let point1 = mapToCurve(fieldElements[0])
        let point2 = mapToCurve(fieldElements[1])

        let point3 = point1 + point2
        let resultPoint = clearCofactor(point3)
        return resultPoint
    }

    /// Takes as input a point on E' and produces as output a point on E
    func isoMap(_ point: Point<F>) -> Point<F> {
        // MARK: Calculating X
        let xNum = calculateNum(point.x, xNumConstants), xDen = calculateDen(point.x, xDenConstants)
        let x = xNum * xDen.modInverse()

        // MARK: Calculating Y
        let yNum = calculateNum(point.x, yNumConstants), yDen = calculateDen(point.x, yDenConstants)
        let y = point.y * yNum * yDen.modInverse()

        let point = Point(x: x, y: y)
        return point.modularized()
    }

    /// Checks whether the given y is negative. Should be used in serialization & deserialization
    func isNegative(_ y: F?) -> Bool {
        let y = {
            if let y = y as? Fq1 { return y.t0 }
            if let y = y as? Fq2 { return y.u1.t0 }
            return 0
        }()

        return y.mod(p) > (p - 1) / 2
    }

    /// Returns a base point on the G subgroup
    func getBasePoint() -> Point<F> { .init(x: BPx, y: BPy) }

    /// Function that defines the basic curve
    func f(_ x: F) -> F { x * x * x + A * x + B }

    /// Characteristic of the field F
    var p: BInt { BBSSettings.ciphersuite.p }

    /// Order of G1 and G2
    var r: BInt { BBSSettings.ciphersuite.r }
}
private extension CurveSuite {
    /// Hashes arbitrary-length byte strings to a list of one or more elements of a finite field F
    func hashToField(_ bytes: [UInt8], _ count: Int, _ customDst: [UInt8]?) throws -> [F] {
        let uniformBytes = try expandMessage.make(
            bytes,
            dst: customDst ?? dst.asAsciiToByteRepresentation(),
            expectedLengthInBytes: count * m * L
        )

        let listOfElements = createListOfElements(uniformBytes, count)
        let fields = listOfElements.map(F.init)
        return fields
    }

    /// Sends any point on the curve E to the subgroup G of E
    func clearCofactor(_ point: Point<F>) -> Point<F> { point * hEff }
}

// MARK: - Iso Map Helpers
private extension CurveSuite {
    func calculateNum(_ x: F, _ array: [F]) -> F {
        var result: F = 0

        for i in 0..<array.count {
            let valueToAdd = array[i] * x.exp(BInt(i))
            result = (result + valueToAdd).mod()
        }

        return result
    }
    func calculateDen(_ x: F, _ array: [F]) -> F {
        var result: F = 0

        for i in 0...array.count {
            let valueToAdd = i < array.count ? array[i] * x.exp(BInt(i)) : x.exp(BInt(i))
            result = (result + valueToAdd).mod()
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
                let element = Array(uniformBytes[elementOffset..<elementOffset + L])
                    .toInteger()
                    .mod(p)

                tempArray.append(element)
            }

            listOfElements.append(tempArray)
        }

        return listOfElements
    }
}
