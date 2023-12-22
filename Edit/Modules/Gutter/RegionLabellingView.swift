import Cocoa

/// A linear region made up of a position and a size.
public struct Region {
	public let position: CGFloat
	public let size: CGFloat

	public init(position: CGFloat, size: CGFloat) {
		self.position = position
		self.size = size
	}
}

extension CGRect {
	var verticalRegion: Region {
		.init(position: origin.y, size: size.height)
	}
}

public struct LabelledRegion {
	public let label: NSAttributedString
	public let background: NSColor?
	public let region: Region

	public init(label: NSAttributedString, background: NSColor? = nil, region: Region) {
		self.label = label
		self.region = region
		self.background = background
	}
}

/// A view that draws region labels vertically within its entire bounds.
public final class RegionLabellingView: NSView {
	public typealias LabelledRegionProvider = (Region) -> ([LabelledRegion])

	private let provider: LabelledRegionProvider

	public var thickness: CGFloat = 1.0 {
		didSet {
			if oldValue != thickness {
				setNeedsDisplay(visibleRect)
				invalidateIntrinsicContentSize()
			}
		}
	}

	public init(regionProvider: @escaping LabelledRegionProvider) {
		self.provider = regionProvider

		super.init(frame: .zero)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override var isFlipped: Bool { true }

	public override var intrinsicContentSize: NSSize {
		return NSSize(width: thickness, height: NSView.noIntrinsicMetric)
	}

	public override func draw(_ dirtyRect: NSRect) {
		let dirtyRegion = dirtyRect.intersection(bounds).verticalRegion

		let labelledRegions = provider(dirtyRegion)

		for labelledRegion in labelledRegions {
			if let color = labelledRegion.background {
				color.setFill()
				NSBezierPath.fill(boundingRectForRegion(labelledRegion.region))
			}

			drawLabelledRegion(labelledRegion)
		}
	}

	private func boundingRectForRegion(_ region: Region) -> NSRect {
		CGRect(x: 0.0, y: region.position, width: bounds.size.width, height: region.size)
	}

	private func drawLabelledRegion(_ labelledRegion: LabelledRegion) {
		let label = labelledRegion.label
		let size = label.size()

		// right-justified and vertically centered
		let horizOffset = bounds.size.width - size.width
		let vertOffset = (labelledRegion.region.size - size.height) / 2.0

		let textRect = CGRect(x: horizOffset,
							  y: labelledRegion.region.position + vertOffset,
							  width: size.width,
							  height: size.height)

		label.draw(with: textRect, options: [.usesLineFragmentOrigin])
	}
}
