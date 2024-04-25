import SwiftUI
import NSUI

public struct RepresentableView<View: NSUIView>: NSUIViewRepresentable {
	public typealias NSUIViewType = View
	public let view: View

	public init(view: View) {
		self.view = view
	}

	public func makeNSUIView(context: Context) -> View {
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}

	public func updateNSUIView(_ view: View, context: Context) {
	}
}
