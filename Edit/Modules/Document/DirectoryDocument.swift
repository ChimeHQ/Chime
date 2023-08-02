import AppKit

public final class DirectoryDocument: BaseDocument {
	public override class var autosavesInPlace: Bool {
		return false
	}

	public override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		switch item.action {
		case #selector(save(_:))?:
			return false
		case #selector(saveAs(_:))?:
			return false
		case #selector(duplicate(_:))?:
			return false
		case #selector(rename(_:))?:
			return false
		case #selector(move(_:))?:
			return false
		case #selector(revertToSaved(_:))?:
			return false
		default:
			break
		}

		return super.validateUserInterfaceItem(item)
	}

	public override func save(_ sender: Any?) {
	}

	public override func saveAs(_ sender: Any?) {
	}

	public override func duplicate(_ sender: Any?) {
	}

	public override func rename(_ sender: Any?) {
	}

	public override func move(_ sender: Any?) {
	}

	public override func revertToSaved(_ sender: Any?) {
	}
}

