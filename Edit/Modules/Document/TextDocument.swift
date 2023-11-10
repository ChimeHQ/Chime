import AppKit
import SwiftUI
import OSLog

import ChimeKit
import ContainedDocument
import Editor
import ProcessEnv
import ProjectWindow
import Utility

public final class TextDocument: ContainedDocument<Project> {
	private lazy var projectWindowController: ProjectWindowController = {
		let editorController = EditorContentViewController()

		return makeProjectWindowController(
			contentViewController: editorController,
			context: state.context
		)
	}()

	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	public var statedChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.state = DocumentState()

	    super.init()
	}

	public var context: DocumentContext {
		state.context
	}

	public override class var autosavesInPlace: Bool {
		return true
	}

	public override func makeWindowControllers() {
		precondition(windowControllers.isEmpty)

		addWindowController(projectWindowController)
	}

	public override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	public override func read(from url: URL, ofType typeName: String) throws {
		try MainActor.assumeIsolated {
			try self.state.read(from: url, typeName: typeName)
		}
	}

	public override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) async throws {
		try await super.save(to: url, ofType: typeName, for: saveOperation)

		// at this point, we can re-check the url for an updated UTI
		let newTypeName = (try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) ?? typeName

		self.state.update(url: url, typeName: newTypeName)
	}

	public override func close() {
		// Closing removes the project, which results in a state mutation and normally kicks off all kinds of work
		self.isClosing = true

		super.close()
	}

	public override var fileURL: URL? {
		didSet {
			// this can be set on a non-main thread
			DispatchQueue.main.asyncUnsafe {
				MainActor.assumeIsolated {
					self.state.update(url: self.fileURL)
				}
			}
		}
	}
}

extension TextDocument {
	private func stateUpdated(_ oldValue: DocumentState) {
		if oldValue == state || isClosing {
			return
		}

		logger.debug("document state changed")

		statedChangedHandler(oldValue, state)
	}
}

extension TextDocument: ProjectDocument {
	var projectState: ProjectState? {
		get { projectWindowController.state }
		set { projectWindowController.state = newValue }
	}

	func willRemoveDocument() {
	}
	
	func didCompleteOpen() {
	}

	var defaultProjectRoot: URL? {
		if ProcessInfo.processInfo.isSandboxed {
			return fileURL
		}

		// we cannot do this when sandboxed
		return fileURL?.deletingLastPathComponent()
	}
}
