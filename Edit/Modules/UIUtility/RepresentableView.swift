import SwiftUI

public struct RepresentableView<View: NSView>: NSViewRepresentable {
	public let view: View

	public init(view: View) {
		self.view = view
	}

	public func makeNSView(context: Context) -> View {
		return view
	}

	public func updateNSView(_ nsView: View, context: Context) {
	}
}
