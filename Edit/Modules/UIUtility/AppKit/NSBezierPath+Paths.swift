import AppKit

public struct RoundedRectRadii {
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

    public init(_ radii: NSBezierPath.Radii) {
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

    public var radiiTuple: NSBezierPath.Radii {
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

extension RoundedRectRadii: Equatable {
}

public extension NSBezierPath {
    typealias Radii = (CGFloat, CGFloat, CGFloat, CGFloat)

    static func roundedPath(rect: NSRect, radii: Radii) -> NSBezierPath {
        let path = NSBezierPath()

        // A -> B
        // |    |
        // D <- C

        let topLeft = rect.minXMaxYPoint
        let topRight = rect.maxXMaxYPoint
        let bottomRight = rect.maxXMinYPoint
        let bottomLeft = rect.minXMinYPoint

        path.move(to: NSPoint(x: topLeft.x, y: topLeft.y - radii.0))
        path.curve(to: NSPoint(x: topLeft.x + radii.0, y: topLeft.y), controlPoint1: topLeft, controlPoint2: topLeft)
        path.line(to: NSPoint(x: topRight.x - radii.1, y: topRight.y))
        path.curve(to: NSPoint(x: topRight.x, y: topRight.y - radii.1), controlPoint1: topRight, controlPoint2: topRight)
        path.line(to: NSPoint(x: bottomRight.x, y: bottomRight.y + radii.2))
        path.curve(to: NSPoint(x: bottomRight.x - radii.2, y: bottomRight.y), controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.line(to: NSPoint(x: bottomLeft.x + radii.3, y: bottomLeft.y))
        path.curve(to: NSPoint(x: bottomLeft.x, y: bottomLeft.y + radii.3), controlPoint1: bottomLeft, controlPoint2: bottomLeft)

        path.close()

        return path
    }

    static func roundedPath(rect: NSRect, radii: RoundedRectRadii) -> NSBezierPath {
        return roundedPath(rect: rect, radii: (radii.topLeading, radii.topTrailing, radii.bottomTrailing, radii.bottomLeading))
    }
}
