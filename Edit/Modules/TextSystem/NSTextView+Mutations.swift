import AppKit

import DocumentContent

extension NSTextView {
	func applyMutations(_ mutations: [TextStorageMutation]) {
		for mutation in mutations {
			for rangedString in mutation.stringMutations {
				replaceCharacters(in: rangedString.range, with: rangedString.string)
			}
		}
	}
}
