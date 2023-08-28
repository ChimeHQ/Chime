import SwiftUI

public struct BottomPushAndSlideEffect: AnimatableModifier {
	public var animatableData: CGFloat {
		didSet { updateSubdata() }
	}

	private var spaceEffect: TrailingSlideEffect
	private var slideEffect: BottomSlideEffect

	public init(visible: Bool) {
		self.animatableData = visible ? 1.0 : 0.0
		self.spaceEffect = TrailingSlideEffect(visible: visible)
		self.slideEffect = BottomSlideEffect(visible: visible)
	}

	private mutating func updateSubdata() {
		let phase1end = 0.7
		let phase2start = 0.7

		let phase1 = animatableData / phase1end
		let phase2 = (animatableData - phase2start) / (1.0 - phase2start)

		self.spaceEffect.animatableData = max(min(phase1, 1.0), 0.0)
		self.slideEffect.animatableData = max(min(phase2, 1.0), 0.0)
	}

	public func body(content: Content) -> some View {
		content
			.modifier(spaceEffect)
			.modifier(slideEffect)
	}
}

