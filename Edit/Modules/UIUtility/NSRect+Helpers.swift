import Foundation

public enum NSRectCentering {
    case vertical
    case horizontal
    case both
}

public extension NSRect {
    func outsetBy(dx: CGFloat, dy: CGFloat) -> NSRect {
        return insetBy(dx: -dx, dy: -dy)
    }

    func insetBy(_ size: NSSize) -> NSRect {
        return insetBy(dx: size.width, dy: size.height)
    }

    func outsetBy(_ size: NSSize) -> NSRect {
        return outsetBy(dx: size.width, dy: size.height)
    }

    func centerWithin(_ rect: NSRect, centering: NSRectCentering = .both) -> NSRect {
        let dx = (rect.width - width) / 2.0
        let dy = (rect.height - height) / 2.0

        switch centering {
        case .horizontal:
            return NSMakeRect(dx + rect.origin.x, rect.origin.y, width, height)
        case .vertical:
            return NSMakeRect(rect.origin.x, dy + rect.origin.y, width, height)
        case .both:
            return NSMakeRect(dx + rect.origin.x, dy + rect.origin.y, width, height)
        }
    }

    var outwardIntegral: NSRect {
        return NSIntegralRectWithOptions(self, .alignAllEdgesOutward)
    }
}

public extension NSRect {
    var minXMaxYPoint: NSPoint {
        return NSPoint(x: minX, y: maxY)
    }

    var maxXMaxYPoint: NSPoint {
        return NSPoint(x: maxX, y: maxY)
    }

    var minXMinYPoint: NSPoint {
        return NSPoint(x: minX, y: minY)
    }

    var maxXMinYPoint: NSPoint {
        return NSPoint(x: maxX, y: minY)
    }

    var center: NSPoint {
        return NSPoint(x: midX, y: midY)
    }
}
