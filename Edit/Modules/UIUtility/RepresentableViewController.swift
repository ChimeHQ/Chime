import SwiftUI

public struct RepresentableViewController<Controller: NSViewController>: NSViewControllerRepresentable {
	public let controller: Controller

	public init(_ controller: Controller) {
		self.controller = controller
	}

	public func makeNSViewController(context: Context) -> some NSViewController {
//		controller.view.translatesAutoresizingMaskIntoConstraints = false

		return controller
	}

	public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
	}
}
