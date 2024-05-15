import AppKit

import ScrollViewPlus

final class EditorScrollView: OverlayOnlyScrollView {
	private lazy var overlayObserver: ScrollerOverlayObserver = {
		ScrollerOverlayObserver(scrollView: self)
	}()

	var scrollerThicknessChangedHandler: (() -> Void)?
	var scrollerVisibilityChangedHandler: (() -> Void)?

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)

		overlayObserver.visibilityChangedHandler = { [unowned self] in
			self.scrollerVisibilityChangedHandler?()
			self.scrollerThicknessChangedHandler?()
		}

		overlayObserver.scrollerThicknessChangedHandler = { [unowned self] in
			self.scrollerThicknessChangedHandler?()
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension EditorScrollView {
	var horizontalScrollerVisible: Bool {
		return overlayObserver.horizontalScrollerVisible
	}

	var verticalScrollerVisible: Bool {
		return overlayObserver.verticalScrollerVisible
	}

	var horizontalScrollerThickness: CGFloat {
		let thickness = horizontalScroller?.knobSlotThickness ?? 0.0

		return horizontalScrollerVisible ? thickness : 0.0
	}

	var verticalScrollerThickness: CGFloat {
		let thickness = verticalScroller?.knobSlotThickness ?? 0.0

		return verticalScrollerVisible ? thickness : 0.0
	}

	var verticalKnobSlotVisible: Bool {
		return verticalScrollerVisible && (verticalScroller?.knobSlotVisible ?? false)
	}

	var horizontalKnobSlotVisible: Bool {
		return horizontalScrollerVisible && (horizontalScroller?.knobSlotVisible ?? false)
	}

	var horizontalMargin: CGFloat {
		let thickness = max(horizontalScrollerThickness, 12.0)

		return horizontalKnobSlotVisible ? thickness + 4.0 : thickness
	}

	var verticalMargin: CGFloat {
		let thickness = max(verticalScrollerThickness, 12.0)

		return verticalKnobSlotVisible ? thickness + 4.0 : thickness
	}

	override func flashScrollers() {
		overlayObserver.flashScrollers()

		super.flashScrollers()
	}

	override func scroll(_ clipView: NSClipView, to point: NSPoint) {
		overlayObserver.scroll(clipView, to: point)

		super.scroll(clipView, to: point)
	}
}

import SwiftUI

class NonSendable {
}

struct MyKey: EnvironmentKey {
	static var defaultValue: NonSendable { NonSendable() }
}
