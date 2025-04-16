import SwiftUI
import NSUI

public struct RepresentableViewController<Controller: NSUIViewController>: NSUIViewControllerRepresentable {
	public typealias NSUIViewControllerType = Controller

	let controller: () -> Controller

	public init(_ controller: @escaping () -> Controller) {
		self.controller = controller
	}

	public func makeNSUIViewController(context: Context) -> Controller {
		controller()
	}

	public func updateNSUIViewController(_ viewController: Controller, context: Context) {
	}
}

extension RepresentableViewController {
	/// Provide a intermediary SwiftUI view for APIs that use `NSViewController`.
	@MainActor
	public static func wrap<Content: View>(controller: Controller, block: (Self) -> Content) -> NSUIHostingController<Content> {
		let represented = RepresentableViewController({ controller })

		let content = block(represented)

		return NSUIHostingController(rootView: content)
	}
}
