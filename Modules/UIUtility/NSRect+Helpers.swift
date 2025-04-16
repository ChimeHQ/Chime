import Foundation

public enum RectCentering {
    case vertical
    case horizontal
    case both
}

public extension CGRect {
    func outsetBy(dx: CGFloat, dy: CGFloat) -> CGRect {
        return insetBy(dx: -dx, dy: -dy)
    }

    func insetBy(_ size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }

    func outsetBy(_ size: CGSize) -> CGRect {
        return outsetBy(dx: size.width, dy: size.height)
    }

    func centerWithin(_ rect: CGRect, centering: RectCentering = .both) -> CGRect {
        let dx = (rect.width - width) / 2.0
        let dy = (rect.height - height) / 2.0

        switch centering {
        case .horizontal:
			return CGRect(x: dx + rect.origin.x, y: rect.origin.y, width: width, height: height)
        case .vertical:
			return CGRect(x: rect.origin.x, y: dy + rect.origin.y, width: width, height: height)
        case .both:
			return CGRect(x: dx + rect.origin.x, y: dy + rect.origin.y, width: width, height: height)
        }
    }

//    var outwardIntegral: CGRect {
//        return NSIntegralRectWithOptions(self, .alignAllEdgesOutward)
//    }
}

public extension CGRect {
    var minXMaxYPoint: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }

    var maxXMaxYPoint: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }

    var minXMinYPoint: CGPoint {
        return CGPoint(x: minX, y: minY)
    }

    var maxXMinYPoint: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }

    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}
