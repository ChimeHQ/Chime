import SwiftUI

public struct TrailingSlideEffect: AnimatableModifier {
	@State private var size = CGSize.zero
	public var animatableData: CGFloat

	public init(visible: Bool) {
		self.animatableData = visible ? 1.0 : 0.0
	}

	private var effectiveWidth: CGFloat {
		return size.width * max(min(animatableData, 1.0), 0.0)
	}

	public func body(content: Content) -> some View {
		Group {
			content
				.fixedSize()
				.onSizeChange { self.size = $0 }
		}
		.frame(width: effectiveWidth, alignment: .leading)
		.clipped()
	}
}
