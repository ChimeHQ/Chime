import AppKit

open class ColorView: ShapeView {
    open var radii: NSBezierPath.Radii {
        didSet {
            let value = self.radii

            self.pathProvider = { (rect) in
                NSBezierPath.roundedPath(rect: rect, radii: value)
            }
        }
    }

    public var color: NSColor {
        get {
            return fillColor!
        }
        set {
            fillColor = newValue
        }
    }

    public init(frame frameRect: NSRect = .zero, color: NSColor, radii: NSBezierPath.Radii) {
        self.radii = radii

        super.init { (rect) in
            return NSBezierPath.roundedPath(rect: rect, radii: radii)
        }

        self.fillColor = color
    }

    public convenience init(frame frameRect: NSRect = .zero, color: NSColor, radii: RoundedRectRadii = .zero) {
        let adaptedRadii = (radii.topLeading, radii.topTrailing, radii.bottomTrailing, radii.bottomLeading)

        self.init(frame: frameRect, color: color, radii: adaptedRadii)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShapeView {
    public static func rect(color: NSColor) -> ShapeView {
        let view = ShapeView { (rect) -> NSBezierPath in
            NSBezierPath(rect: rect)
        }

        view.fillColor = color

        return view
    }

    public static func roundedRect(color: NSColor? = nil, radii: NSBezierPath.Radii) -> ShapeView {
        let view = ShapeView { (rect) -> NSBezierPath in
            NSBezierPath.roundedPath(rect: rect, radii: radii)
        }

        view.fillColor = color

        return view
    }
}
