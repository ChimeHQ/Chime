import SwiftUI

import DocumentContent

@MainActor
final class ContentInvalidationHandler: NSObject, ObservableObject {
	typealias Action = (IndexSet) -> Void

	let notificationName: Notification.Name
	let setKey: String
	var action: Action = { _ in }

	init(notificationName: Notification.Name, setKey: String) {
		self.notificationName = notificationName
		self.setKey = setKey
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func register(_ system: TextViewSystem?) {
		let center = NotificationCenter.default

		center.removeObserver(self)

		guard let system else { return }

		center.addObserver(
			self,
			selector: #selector(invalidated(_:)),
			name: notificationName,
			object: system
		)
	}

	@objc private func invalidated(_ notification: Notification) {
		let set = notification.userInfo?[setKey] as! IndexSet

		action(set)
	}
}

@MainActor
struct InvalidationNotificationMonitorModifier: ViewModifier {
	@Environment(\.textViewSystem) private var system

	@State private var handler = ContentInvalidationHandler(
		notificationName: TextMetrics.textMetricsDidChangeNotification,
		setKey: TextMetrics.invalidationSetKey
	)

	init(action: @escaping ContentInvalidationHandler.Action) {
		handler.action = action
	}

	func body(content: Content) -> some View {
		content
			.onChange(of: system, initial: true, { _, new in handler.register(new) })
	}
}

extension View {
	/// Observe content mutation phases applied to the current document.
	@MainActor
	public func onTextMetricsInvalidation(_ action: @escaping (IndexSet) -> Void) -> some View {
		modifier(InvalidationNotificationMonitorModifier(action: action))
	}
}

