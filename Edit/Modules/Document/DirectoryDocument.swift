import AppKit
import SwiftUI

import ChimeKit
import ContainedDocument
import ProjectWindow

extension DocumentContext {
	/// This is a placeholder representing a non-document.
	///
	/// It exists to avoid annoying optionals or create a second form of ProjectWindowController.
	static let nonDocumentContext = DocumentContext()
}

public final class DirectoryDocument: ContainedDocument<Project> {
	private let projectWindowController: ProjectWindowController

	override init() {
		let placeholderController = NSHostingController(rootView: Color.orange)

		self.projectWindowController = ProjectWindowController(
			contentViewController: placeholderController,
			documentContext: .nonDocumentContext
		)

		super.init()
	}

	public override func makeWindowControllers() {
		precondition(windowControllers.isEmpty)

		addWindowController(projectWindowController)
	}

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

	public override func save(_ sender: Any?) {}
	public override func saveAs(_ sender: Any?) {}
	public override func duplicate(_ sender: Any?) {}
	public override func rename(_ sender: Any?) {}
	public override func move(_ sender: Any?) {}
	public override func revertToSaved(_ sender: Any?) {}

	public override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
		if fileURL == nil {
			throw NSError(domain: NSOSStatusErrorDomain, code: openErr)
		}
	}
}

extension DirectoryDocument: ProjectDocument {
	var projectContext: ProjectContext? {
		get { projectWindowController.projectContext }
		set { projectWindowController.projectContext = newValue }
	}

	func willRemoveDocument() {
	}
	
	func didCompleteOpen() {
	}

	var defaultProjectRoot: URL? {
		fileURL
	}
}
