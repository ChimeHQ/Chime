import NSUI

import DocumentContent

extension NSUITextView {
	func applyMutation(_ mutation: TextStorageMutation) {
		guard let storage = nsuiTextStorage else { fatalError() }

		storage.replaceCharacters(in: mutation.range, with: mutation.string)
	}
}
