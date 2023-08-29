import AppKit

public class ShapeLayerController: NSObject, CALayerDelegate {
    public typealias PathProviderBlock = (NSRect) -> NSBezierPath

    public var pathProvider: PathProviderBlock

    public init(pathProvider: @escaping PathProviderBlock) {
        self.pathProvider = pathProvider

        super.init()
    }

    public func display(_ layer: CALayer) {
        let rect = layer.bounds

        if rect.isEmpty || rect.isInfinite {
            return
        }

        let path = pathProvider(rect)

        guard let layer = layer as? CAShapeLayer else {
            fatalError("delegate of a non CAShapeLayer")
        }

        layer.path = path.cgPath
    }

    public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
}
