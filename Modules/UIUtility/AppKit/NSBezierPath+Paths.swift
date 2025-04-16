import NSUI

public struct RoundedRectRadii: Sendable, Hashable {
    public let topLeading: CGFloat
    public let bottomLeading: CGFloat
    public let topTrailing: CGFloat
    public let bottomTrailing: CGFloat

    public init(topLeading: CGFloat, bottomLeading: CGFloat, topTrailing: CGFloat, bottomTrailing: CGFloat) {
        self.topLeading = topLeading
        self.bottomLeading = bottomLeading
        self.topTrailing = topTrailing
        self.bottomTrailing = bottomTrailing
    }

    public init(_ radii: NSUIBezierPath.Radii) {
        self.topLeading = radii.0
        self.topTrailing = radii.1
        self.bottomTrailing = radii.2
        self.bottomLeading = radii.3
    }

    public var maximumLeadingRadius: CGFloat {
        return max(topLeading, bottomLeading)
    }

    public var maximumTrailingRadius: CGFloat {
        return max(bottomTrailing, topTrailing)
    }

    public var maximum: CGFloat {
        return max(topLeading, bottomLeading, topTrailing, bottomTrailing)
    }

    public var radiiTuple: NSUIBezierPath.Radii {
        (topLeading, topTrailing, bottomTrailing, bottomLeading)
    }

    public static func leading(radius: CGFloat) -> RoundedRectRadii {
        return RoundedRectRadii(topLeading: radius, bottomLeading: radius, topTrailing: 0.0, bottomTrailing: 0.0)
    }

    public static func trailing(radius: CGFloat) -> RoundedRectRadii {
        return RoundedRectRadii(topLeading: 0.0, bottomLeading: 0.0, topTrailing: radius, bottomTrailing: radius)
    }

    public static func top(radius: CGFloat) -> RoundedRectRadii {
        return RoundedRectRadii(topLeading: radius, bottomLeading: 0.0, topTrailing: radius, bottomTrailing: 0.0)
    }

    public static func bottom(radius: CGFloat) -> RoundedRectRadii {
        return RoundedRectRadii(topLeading: 0.0, bottomLeading: radius, topTrailing: 0.0, bottomTrailing: radius)
    }

    public static func all(radius: CGFloat) -> RoundedRectRadii {
        return RoundedRectRadii(topLeading: radius, bottomLeading: radius, topTrailing: radius, bottomTrailing: radius)
    }

    public static let zero = RoundedRectRadii(topLeading: 0.0, bottomLeading: 0.0, topTrailing: 0.0, bottomTrailing: 0.0)
}

public extension NSUIBezierPath {
    typealias Radii = (CGFloat, CGFloat, CGFloat, CGFloat)

    static func roundedPath(rect: CGRect, radii: Radii) -> NSUIBezierPath {
        let path = NSUIBezierPath()

        // A -> B
        // |    |
        // D <- C

        let topLeft = rect.minXMaxYPoint
        let topRight = rect.maxXMaxYPoint
        let bottomRight = rect.maxXMinYPoint
        let bottomLeft = rect.minXMinYPoint

        path.move(to: CGPoint(x: topLeft.x, y: topLeft.y - radii.0))
        path.addCurve(to: CGPoint(x: topLeft.x + radii.0, y: topLeft.y), controlPoint1: topLeft, controlPoint2: topLeft)
		path.addLine(to: CGPoint(x: topRight.x - radii.1, y: topRight.y))
        path.addCurve(to: CGPoint(x: topRight.x, y: topRight.y - radii.1), controlPoint1: topRight, controlPoint2: topRight)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y + radii.2))
        path.addCurve(to: CGPoint(x: bottomRight.x - radii.2, y: bottomRight.y), controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.addLine(to: CGPoint(x: bottomLeft.x + radii.3, y: bottomLeft.y))
        path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y + radii.3), controlPoint1: bottomLeft, controlPoint2: bottomLeft)

        path.close()

        return path
    }

    static func roundedPath(rect: CGRect, radii: RoundedRectRadii) -> NSUIBezierPath {
        return roundedPath(rect: rect, radii: (radii.topLeading, radii.topTrailing, radii.bottomTrailing, radii.bottomLeading))
    }
}
