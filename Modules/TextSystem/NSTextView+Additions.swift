import NSUI

extension NSUITextView {
	func replaceTextStorage(_ newStorage: NSTextStorage) {
		if let contentStorage = nsuiTextContentStorage {
			contentStorage.textStorage = newStorage
			return
		}

		if let layoutManager = nsuiLayoutManager {
			layoutManager.replaceTextStorage(newStorage)
			return
		}

		fatalError("unable to swap the text storage")
	}
}
