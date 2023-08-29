import AppKit

open class ShapeView: NSView {
    private let shapeLayerController: ShapeLayerController
    private let shapeLayer: CAShapeLayer

    var pathProvider: (NSRect) -> NSBezierPath {
        get {
            return shapeLayerController.pathProvider
        }
        set {
            shapeLayerController.pathProvider = newValue
            shapeLayer.setNeedsDisplay()
        }
    }

    public var rotationInDegrees: CGFloat = 0.0 {
        didSet {
            let radians = self.rotationInDegrees.degreesToRadians()

            shapeLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        }
    }

    public var strokeColor: NSColor? {
        didSet {
            shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }

    public var fillColor: NSColor? {
        didSet {
            shapeLayer.fillColor = fillColor?.cgColor
        }
    }

    public var lineWidth: CGFloat = 1.0 {
        didSet {
            shapeLayer.lineWidth = lineWidth
        }
    }

    public init(pathProvider: @escaping (NSRect) -> NSBezierPath) {
        self.shapeLayerController = ShapeLayerController(pathProvider: pathProvider)
        self.shapeLayer = CAShapeLayer()

        super.init(frame: NSRect.zero)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func makeBackingLayer() -> CALayer {
        let mainLayer = CALayer()

        mainLayer.addSublayer(shapeLayer)

        shapeLayer.delegate = shapeLayerController
        shapeLayer.needsDisplayOnBoundsChange = true

        return mainLayer
    }

    public override func layout() {
        super.layout()

        guard let bounds = layer?.bounds else {
            return
        }

        // prevent animations while adjusting our layer properties
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let halfWidth = bounds.width / 2.0
        let halfHeight = bounds.height / 2.0

        shapeLayer.position = CGPoint(x: halfWidth, y: halfHeight)
        shapeLayer.bounds = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)

        CATransaction.commit()
    }

    public override func viewDidChangeEffectiveAppearance() {
        // I'm not entirely sure this is still neccessary...
        effectiveAppearance.performAsCurrentDrawingAppearance {
            shapeLayer.fillColor = fillColor?.cgColor
            shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }
}

extension ShapeView {
    public func startRotationAnimation(duration: Double, clockwise: Bool) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duration
        animation.repeatCount = Float.infinity

        let factor = clockwise ? 1.0 : -1.0

        animation.byValue =  factor * 2.0 * Double.pi

        shapeLayer.add(animation, forKey: "transform.rotation.z")
    }

    public func stopAllAnimations() {
        shapeLayer.removeAllAnimations()
    }

    public static func hexagon(lineWidth: CGFloat) -> ShapeView {
        let view = ShapeView { (rect) -> NSBezierPath in

            // must inset by lineThickness
            let insetRect = rect.insetBy(dx: lineWidth, dy: lineWidth)
            if insetRect.isEmpty || insetRect.isInfinite {
                return NSBezierPath(rect: rect)
            }

            return HexagonView.hexagonPath(within: insetRect)
        }

        view.lineWidth = lineWidth
        view.fillColor = nil

        return view
    }
}
