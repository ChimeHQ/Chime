import NSUI

import DocumentContent

extension NSUITextView {
	func applyMutations(_ mutations: [TextStorageMutation]) {
		guard let storage = nsuiTextStorage else { fatalError() }

		for mutation in mutations {
			for rangedString in mutation.stringMutations {
				storage.replaceCharacters(in: rangedString.range, with: rangedString.string)
			}
		}
	}
}
