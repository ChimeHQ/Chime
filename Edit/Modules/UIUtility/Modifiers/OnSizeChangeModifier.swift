import SwiftUI

private struct SizePreferenceKey: PreferenceKey {
	static let defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct OnSizeChangeModifier: ViewModifier {
	let block: (CGSize) -> Void

	func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometryProxy in
					Color.clear
						.preference(key: SizePreferenceKey.self, value: geometryProxy.size)
				}
			)
			.onPreferenceChange(SizePreferenceKey.self, perform: block)
	}
}

extension View {
	/// Executes a block when the view's siew changes.
	public func onSizeChange(perform block: @escaping (CGSize) -> Void) -> some View {
		modifier(OnSizeChangeModifier(block: block))
	}
}

