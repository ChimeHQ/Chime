import AppKit
import SwiftUI

import ChimeKit
import ContainedDocument
import DocumentContent
import ExtensionHost
import ProjectWindow

extension DocumentContext {
	/// This is a placeholder representing a non-document.
	///
	/// It exists to avoid annoying optionals or create a second form of ProjectWindowController.
	static let nonDocumentContext = DocumentContext()
}

public final class DirectoryDocument: ContainedDocument<Project> {
	private lazy var projectWindowController: ProjectWindowController = { @MainActor in
		let placeholderController = NSHostingController(rootView: Color.orange)
		let store = ProjectDocumentController.sharedController.themeStore
		let model = WindowStateModel(context: .nonDocumentContext, themeStore: store)

		return makeProjectWindowController(
			contentViewController: placeholderController,
			model: model
		)
	}()

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
	public var projectState: ProjectState? {
		get { projectWindowController.state }
		set { projectWindowController.state = newValue }
	}

	public var defaultProjectRoot: URL? {
		fileURL
	}

	public func updateApplicationService(_ service: ExtensionRouter) {
		projectWindowController.symbolQueryService = try? projectContext.flatMap { try service.symbolService(for: $0) }
	}

	public func willRemoveDocument() {
	}
	
	public func didCompleteOpen() {
	}
}
