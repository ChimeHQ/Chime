import SwiftUI

//final class MutationHandlers: NSObject, ObservableObject {
//	typealias Handler = ([TextStorageMutation]) -> Void
//
//	var willApply: Handler = { _ in }
//	var didApply: Handler = { _ in }
//	var didComplete: Handler = { _ in }
//
//	deinit {
//		NotificationCenter.default.removeObserver(self)
//	}
//
//	func register(_ content: DocumentContent?) {
//		let center = NotificationCenter.default
//
//		center.removeObserver(self)
//
//		guard let content else { return }
//
//		center.addObserver(
//			self,
//			selector: #selector(willApply(_:)),
//			name: DocumentContent.willApplyMutationsNotification,
//			object: content
//		)
//
//		center.addObserver(
//			self,
//			selector: #selector(didApply(_:)),
//			name: DocumentContent.didApplyMutationsNotification,
//			object: content
//		)
//	}
//
//	@objc private func willApply(_ notification: Notification) {
//		let mutations = notification.userInfo?[DocumentContent.textStorageMutationsKey] as! [TextStorageMutation]
//
//		willApply(mutations)
//	}
//
//	@objc private func didApply(_ notification: Notification) {
//		let mutations = notification.userInfo?[DocumentContent.textStorageMutationsKey] as! [TextStorageMutation]
//
//		didApply(mutations)
//	}
//}
//
//struct DocumentMutationMonitorModifier: ViewModifier {
//	typealias Handler = MutationHandlers.Handler
//
//	@State private var handlers = MutationHandlers()
//
//	init(willApply: @escaping Handler, didApply: @escaping Handler, didComplete: @escaping Handler) {
//		handlers.willApply = willApply
//		handlers.didApply = didApply
//		handlers.didComplete = didComplete
//	}
//
//	func body(content: Content) -> some View {
//		content
//			.onDocumentContentChange { handlers.register($0) }
//	}
//}
//
//extension View {
//	/// Observe content mutation phases applied to the current document.
//	public func onDocumentMutation(
//		willApply: @escaping ([TextStorageMutation]) -> Void = { _ in },
//		didApply: @escaping ([TextStorageMutation]) -> Void,
//		didComplete: @escaping ([TextStorageMutation]) -> Void = { _ in }
//	) -> some View {
//		modifier(DocumentMutationMonitorModifier(willApply: willApply, didApply: didApply, didComplete: didComplete))
//	}
//}
