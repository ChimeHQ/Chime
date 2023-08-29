import AppKit

public class HexagonView: NSView {

    public var strokeColor: NSColor = NSColor.black
    public var fillColor: NSColor = NSColor.white

    public static let sinComponent = sin(CGFloat.pi / 3.0)
    public static let cosComponent = cos(CGFloat.pi / 3.0)

    public override func draw(_ dirtyRect: NSRect) {
        let length = self.bounds.width / 2.0
        let center = NSPoint(x: length, y: self.bounds.height / 2.0)

        let path = HexagonView.hexagonPath(at: center, sideLength: length)

        self.fillColor.setFill()
        path.fill()

        self.strokeColor.setStroke()
        path.stroke()
    }

    public static func hexagonPath(at center: NSPoint, sideLength length: CGFloat) -> NSBezierPath {
        let cosValue = HexagonView.cosComponent * length
        let sinValue = HexagonView.sinComponent * length

        let path = NSBezierPath()

        path.move(to: NSPoint(x: center.x - cosValue, y: center.y + sinValue))
        path.line(to: NSPoint(x: center.x + cosValue, y: center.y + sinValue))
        path.line(to: NSPoint(x: center.x + length, y: center.y))
        path.line(to: NSPoint(x: center.x + cosValue, y: center.y - sinValue))
        path.line(to: NSPoint(x: center.x - cosValue, y: center.y - sinValue))
        path.line(to: NSPoint(x: center.x - length, y: center.y))
        path.close()

        return path
    }

    public static func hexagonPath(within rect: NSRect) -> NSBezierPath {
        // defend against nonsense rectangles
        precondition(!rect.isEmpty && !rect.isInfinite)

        let center = rect.center
        let shortestSideLength = min(rect.width, rect.height)

        // shortestSideLength = length + 2 * (HexagonView.cosComponent * length)
        // shortestSideLength/length = 1 + 2 * HexagonView.cosComponent
        // 1 / length = (1 + 2 * HexagonView.cosComponent) / shortestSideLength

        let length = shortestSideLength / (1.0 + 2.0 * HexagonView.cosComponent)

        return hexagonPath(at: center, sideLength: length)
    }

    public static func hexagonImage(length: CGFloat, fillColor: NSColor, strokeColor: NSColor) -> NSImage {
        return NSImage(size: NSSize(width: length * 2.0, height: length * 2.0), flipped: false, drawingHandler: { (rect) -> Bool in
            let path = HexagonView.hexagonPath(at: NSPoint(x: length, y: length), sideLength: length)
            fillColor.setFill()
            path.fill()

            strokeColor.setStroke()
            path.stroke()

            return true
        })
    }

}
