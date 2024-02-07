import AppKit

extension NSTextView {
	func replaceTextStorage(_ newStorage: NSTextStorage) {
		if let contentStorage = textContentStorage {
			contentStorage.textStorage = newStorage
			return
		}

		if let layoutManager = layoutManager {
			layoutManager.replaceTextStorage(newStorage)
			return
		}

		fatalError("unable to swap the text storage")
	}
}
