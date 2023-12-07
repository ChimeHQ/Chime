import AppKit
import Foundation

enum TextStorageError: Error {
	case underlyingStorageInvalid
	case rangeInvalid(NSRange, Int)
}

extension TextStorage {
	public static let null = TextStorage(
		beginEditing: {},
		endEditing: {},
		applyMutation: { _ in },
		length: { 0 },
		substring: { throw TextStorageError.rangeInvalid($0, 0) }
	)

	@MainActor
	public init(textView: NSTextView) {
		self.beginEditing = { textView.textStorage?.beginEditing() }
		self.endEditing = {
			textView.textStorage?.endEditing()

			textView.didChangeText()
		}

		self.applyMutation = {
			for mutation in $0 {
				for rangedString in mutation.stringMutations {
					textView.replaceCharacters(in: rangedString.range, with: rangedString.string)
				}
			}
		}

		self.length = { textView.textStorage?.length ?? 0 }
		self.substring = {
			guard let storage = textView.textStorage else {
				throw TextStorageError.underlyingStorageInvalid
			}

			guard let value = storage.substring(from: $0) else {
				throw TextStorageError.rangeInvalid($0, storage.length)
			}

			return value
		}
	}

	public init(textStorage: NSTextStorage) {
		self.beginEditing = { textStorage.beginEditing() }
		self.endEditing = { textStorage.endEditing() }

		self.applyMutation = {
			for mutation in $0 {
				for rangedString in mutation.stringMutations {
					textStorage.replaceCharacters(in: rangedString.range, with: rangedString.string)
				}
			}
		}

		self.length = { textStorage.length }
		self.substring = {
			guard let value = textStorage.substring(from: $0) else {
				throw TextStorageError.rangeInvalid($0, textStorage.length)
			}

			return value
		}

	}
}
