public extension BinaryFloatingPoint {
    func radiansToDegress() -> Self {
        return self * 180.0 / .pi
    }

    func degreesToRadians() -> Self {
        return self * .pi / 180.0
    }
}
