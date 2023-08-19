import SwiftUI

struct NavigatorScrollView<Content: View>: NSViewRepresentable {
	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	func makeNSView(context: Context) -> NSScrollView {
		let view = NSScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false

		view.drawsBackground = true
		view.backgroundColor = .red
		view.hasVerticalScroller = true
		view.automaticallyAdjustsContentInsets = false

		let clipView = view.contentView
		let hostingView = NSHostingView(rootView: content)

		view.documentView = hostingView

		hostingView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			hostingView.topAnchor.constraint(equalTo: clipView.topAnchor),
			hostingView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
			hostingView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
		])

		return view
	}

	func updateNSView(_ view: NSScrollView, context: Context) {
		(view.documentView as! NSHostingView).rootView = content
	}
}
