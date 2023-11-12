import AppKit
import SwiftUI
import OSLog

import ChimeKit
import ContainedDocument
import DocumentContent
import Editor
import ProcessEnv
import ProjectWindow
import Theme
import Utility

public final class TextDocument: ContainedDocument<Project> {
	private lazy var editorContentController = EditorContentViewController(content: self.state.content)
	private lazy var projectWindowController = makeProjectWindowController(
		contentViewController: editorContentController,
		context: state.context
	)

	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	private let contentMonitor = StorageMonitor()
	public var stateChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.state = DocumentState()

	    super.init()

		contentMonitor.monitor(state.content)
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
			let window = projectWindowController.window
			let theme = projectWindowController.theme

			let attrs = theme.typingAttributes(tabWidth: state.context.configuration.tabWidth, context: .init(window: window))
			
			try self.state.read(from: url, typeName: typeName, documentAttributes: attrs)
		}
	}

	public override func save(
		to url: URL,
		ofType typeName: String,
		for saveOperation: NSDocument.SaveOperationType,
		completionHandler: @escaping (Error?) -> Void
	) {
		super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: {
			let newTypeName = (try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) ?? typeName

			self.state.update(url: url, typeName: newTypeName)

			completionHandler($0)
		})
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

	public func updateApplicationService(_ service: any ApplicationService) {
		do {
			projectWindowController.symbolQueryService = try projectContext.flatMap { try service.symbolService(for: $0) }

			Swift.print("service is now: ", projectWindowController.symbolQueryService)
		} catch {
			logger.error("Failed to update symbolService: \(error, privacy: .public)")
		}
	}
}

extension TextDocument {
	private func stateUpdated(_ oldValue: DocumentState) {
		if oldValue == state || isClosing {
			return
		}

		logger.debug("document state changed")
		contentMonitor.monitor(state.content)

		editorContentController.representedObject = state.content

		stateChangedHandler(oldValue, state)
	}
}

extension TextDocument: ProjectDocument {
	var projectState: ProjectState? {
		get { projectWindowController.state }
		set {
			self.state.updateProjectContext(newValue?.context)
			projectWindowController.state = newValue
		}
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
