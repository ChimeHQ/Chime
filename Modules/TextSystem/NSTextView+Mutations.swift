import NSUI

import DocumentContent

extension NSUITextView {
	func applyMutation(_ mutation: TextStorageMutation) {
		guard let storage = nsuiTextStorage else { fatalError() }

		storage.beginEditing()
		let initialText = storage.length == 0

		storage.replaceCharacters(in: mutation.range, with: mutation.string)

		if initialText {
			let affectedRange = NSRange(0..<mutation.string.utf16.count)
			storage.setAttributes(typingAttributes, range: affectedRange)
		}

		storage.endEditing()
	}
}
