import AppKit

public final class ColorView: NSView {
	public var color: NSColor {
		didSet {
			setNeedsDisplay(bounds)
		}
	}

	private let flippedFlag: Bool

	public init(color: NSColor, flipped: Bool = false) {
		self.color = color
		self.flippedFlag = flipped

		super.init(frame: .zero)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override var isFlipped: Bool {
		flippedFlag
	}
	
	public override var isOpaque: Bool {
		color.alphaComponent >= 1.0
	}

	public override func draw(_ dirtyRect: NSRect) {
		NSColor.clear.setFill()
		NSBezierPath.fill(dirtyRect)

		color.setFill()
		NSBezierPath.fill(bounds.intersection(dirtyRect))
	}
}
