import AppKit
import SwiftUI
import OSLog

import ChimeKit
import ContainedDocument
import DocumentContent
import Editor
import ProcessEnv
import ProjectWindow
import TextStory
import Theme
import Utility

public final class TextDocument: ContainedDocument<Project> {
	private let editorContentController: EditorContentViewController
	private let sourceViewController: SourceViewController
	private lazy var projectWindowController = makeProjectWindowController(
		contentViewController: editorContentController,
		context: state.context,
		content: state.content
	)

	private let storageDispatcher: TextStorageDispatcher
	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	public var stateChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.state = DocumentState()
		self.sourceViewController = SourceViewController()
		self.editorContentController = EditorContentViewController(sourceViewController: sourceViewController)
		self.storageDispatcher = TextStorageDispatcher(monitors: [
			state.content.metrics.textStorageMonitor,
			state.content.notificationMonitor,
		])

	    super.init()

		contentUpdated()
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
			let theme = projectWindowController.theme

			try sourceViewController.reload(from: url, documentConfiguration: state.context.configuration, theme: theme)

			self.state.content.replaceStorage(sourceViewController.storage)
			self.state.update(url: url, typeName: typeName)
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
}

extension TextDocument {
	private func contentUpdated() {
	}

	private func stateUpdated(_ oldValue: DocumentState) {
		if oldValue == state || isClosing {
			return
		}

		logger.debug("document state changed")
		contentUpdated()

		projectWindowController.documentContent = state.content

		stateChangedHandler(oldValue, state)
	}
}

extension TextDocument: ProjectDocument {
	public var projectState: ProjectState? {
		get { projectWindowController.state }
		set {
			self.state.updateProjectContext(newValue?.context)
			projectWindowController.state = newValue
		}
	}

	public var defaultProjectRoot: URL? {
		if ProcessInfo.processInfo.isSandboxed {
			return fileURL
		}

		// we cannot do this when sandboxed
		return fileURL?.deletingLastPathComponent()
	}

	public func updateApplicationService(_ service: any ApplicationService) {
		do {
			projectWindowController.symbolQueryService = try projectContext.flatMap { try service.symbolService(for: $0) }
		} catch {
			logger.error("Failed to update symbolService: \(error, privacy: .public)")
		}
	}
	
	public func willRemoveDocument() {
	}
	
	public func didCompleteOpen() {
	}
}
