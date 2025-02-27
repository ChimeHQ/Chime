import Foundation

import ChimeKit
import DocumentContent
import NSUI
import TextStory
import Theme

/// Interface between the core text system and the rest of the application.
///
/// While this type does conform to `NSTextViewDelegate`, it will not automatically become the text view delegate. It will both manage and become the delegte of the view's storage.
@MainActor
public final class TextViewSystem: NSObject {
	public typealias Version = Int
	public typealias Storage = TextStorage<Version>

	private var contentVersion = 0
	public private(set) var contentIdentity = DocumentContentIdentity()

	let textView: NSUITextView
	public private(set) var textMetrics: TextMetrics
	public var willLayoutHandler: () -> Void = {}
	public var didLayoutHandler: () -> Void = {}
	public var contentReplaced: () -> Void = {}

	public init(textView: NSUITextView) {
		self.textView = textView
		self.textMetrics = TextMetrics(storage: Storage.null())

		super.init()

		replaceTextStorage(TSYTextStorage())
	}
}

extension TextViewSystem {
	public var textLayout: TextLayout {
		TextLayout(textView: textView)
	}
}

extension TextViewSystem {
	public var storage: Storage {
		Storage(
			beginEditing: { [unowned self] in self.beginEditing() },
			endEditing: { [unowned self] in self.endEditing() },
			applyMutation: { [unowned self] in self.textView.applyMutation($0) },
			version: { [unowned self] in self.self.contentVersion },
			length: { [unowned self] in self.self.length(for: $0) },
			substring: { [unowned self] in try self.substring(range: $0, version: $1) }
		)
	}

	private func beginEditing() {
		textView.nsuiTextStorage?.beginEditing()
	}

	private func endEditing() {
		textView.nsuiTextStorage?.endEditing()

		contentVersion += 1

#if os(macOS)
		textView.didChangeText()
#endif
	}

	private func length(for version: Version) -> Int? {
		guard contentVersion == version else {
			return nil
		}

		return textView.nsuiTextStorage?.length
	}

	private func substring(range: NSRange, version: Version) throws -> String {
		guard let storage = textView.nsuiTextStorage else {
			throw TextStorageError.underlyingStorageInvalid
		}

		guard version == contentVersion else {
			throw TextStorageError.stale
		}

		guard let value = storage.substring(from: range) else {
			throw TextStorageError.rangeInvalid(range, length: storage.length)
		}

		return value
	}
}

extension TextViewSystem {
	public var textPresentation: TextPresentation {
		TextPresentation(textView: textView)
	}
}

extension TextViewSystem {
	public var storageMonitor: TextStorageMonitor {
		TextStorageMonitor(
			monitors: [
				notificationMonitor,
				indirectMetricsMonitor,
			]
		)
	}

	private var indirectMetricsMonitor: TextStorageMonitor {
		TextStorageMonitor(
			monitorProvider: {
				self.textMetrics.textStorageMonitor
			}
		)
	}
}

extension TextViewSystem {
	public nonisolated static let textStorageMutationsKey = "mutations"
	public nonisolated static let willApplyMutationsNotification = Notification.Name("willApplyMutationsNotification")
	/// It is very strongly recommended to restrict events only to the actual document content you are interested in. If it is not used, you will receive events from all open documents.
	public nonisolated static let didApplyMutationsNotification = Notification.Name("didApplyMutationsNotification")

	private func postEvent(_ named: Notification.Name, _ mutation: TextStorageMutation) {
		NotificationCenter.default.post(
			name: named,
			object: self,
			userInfo: [Self.textStorageMutationsKey: mutation]
		)
	}

	private var notificationMonitor: TextStorageMonitor {
		.init(
			willApplyMutation: { [weak self] in self?.postEvent(Self.willApplyMutationsNotification, $0) },
			didApplyMutation: { [weak self] in self?.postEvent(Self.didApplyMutationsNotification, $0) }
		)
	}
}

extension TextViewSystem {
	private func replaceTextStorage(_ textStorage: TSYTextStorage) {
		textView.replaceTextStorage(textStorage)

		// create a fresh copy here because everything has changed
		self.textMetrics = TextMetrics(storage: storage)

		textMetrics.invalidationHandler = {
			let set = $0.indexSet(with: textStorage.length)

			NotificationCenter.default.post(
				name: TextMetrics.textMetricsDidChangeNotification,
				object: self,
				userInfo: [TextMetrics.invalidationSetKey: set]
			)
		}

		textStorage.storageDelegate = self

		self.contentVersion += 1
		self.contentIdentity = DocumentContentIdentity()
	}

	public func reload(from url: URL, attributes: [NSAttributedString.Key: Any]) throws {
		let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
			.defaultAttributes: attributes,
			.documentType: NSAttributedString.DocumentType.plain,
		]

		let storage = try TSYTextStorage(url: url, options: options, documentAttributes: nil)

		replaceTextStorage(storage)
	}

	public func write(to url: URL) throws {
		try storage.string.write(to: url, atomically: true, encoding: .utf8)
	}

	public func themeChanged(attributes: [NSAttributedString.Key: Any]) {
		guard let storage = textView.nsuiTextStorage else {
			fatalError("")
		}

		storage.beginEditing()
		storage.setAttributes(attributes, range: storage.fullRange)
		storage.endEditing()
	}
}

extension TextViewSystem: TSYTextStorageDelegate {
#if os(macOS)
	public nonisolated func textStorage(_ textStorage: TSYTextStorage, doubleClickRangeForLocation location: UInt) -> NSRange {
		textStorage.internalStorage.doubleClick(at: Int(location))
	}

	public nonisolated func textStorage(_ textStorage: TSYTextStorage, nextWordIndexFromLocation location: UInt, direction forward: Bool) -> UInt {
		UInt(textStorage.internalStorage.nextWord(from: Int(location), forward: forward))
	}
#endif

	public nonisolated func textStorageWillCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		MainActor.assumeIsolated {
			willLayoutHandler()
		}
	}

	public nonisolated func textStorageDidCompleteProcessingEdit(_ textStorage: TSYTextStorage) {
		MainActor.assumeIsolated {
			didLayoutHandler()
		}
	}
}
