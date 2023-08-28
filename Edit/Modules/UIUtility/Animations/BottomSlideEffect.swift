import SwiftUI

public struct BottomSlideEffect: AnimatableModifier {
	@State private var size = CGSize.zero
	public var animatableData: CGFloat

	public init(visible: Bool) {
		self.animatableData = visible ? 1.0 : 0.0
	}

	private var effectiveWidth: CGFloat {
		return size.width * animatableData
	}

	private var effectiveHeight: CGFloat {
		return size.height * animatableData
	}

	public func body(content: Content) -> some View {
		ZStack(alignment: .bottom) {
			Rectangle()
				.hidden()
				.frame(width: size.width, height: size.height)
			Group {
				content
					.fixedSize()
					.onSizeChange { self.size = $0 }
			}
			.frame(height: effectiveHeight, alignment: .top)
			.clipped()
		}

	}
}

