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
import TextSystem
import Theme
import Utility

public final class TextDocument: ContainedDocument<Project> {
	typealias StorageDispatcher = TextStorageDispatcher<TextViewSystem.Version>

	private let editorContentController: EditorContentViewController
	private let sourceViewController: SourceViewController
	private lazy var projectWindowController = makeProjectWindowController(
		contentViewController: editorContentController,
		context: state.context
	)

	private let textSystem: TextViewSystem
	private let storageDispatcher: StorageDispatcher
	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	public var stateChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.sourceViewController = SourceViewController()
		self.textSystem = TextViewSystem(textView: sourceViewController.textView)

		self.state = DocumentState(contentId: textSystem.contentIdentity)

		self.editorContentController = EditorContentViewController(textSystem: textSystem, sourceViewController: sourceViewController)
		let dispatcher = StorageDispatcher(storage: textSystem.storage, monitors: [
			textSystem.storageMonitor,
		])

		self.storageDispatcher = dispatcher

	    super.init()

		let textView = sourceViewController.textView

		sourceViewController.shouldChangeTextHandler = {
			dispatcher.textView(textView, shouldChangeTextIn: $0, replacementString: $1)
		}
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
			let config = state.context.configuration
			let theme = projectWindowController.theme
			let context = Theme.Context(window: projectWindowController.window)
			let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)

			try textSystem.reload(from: url, attributes: attrs)

			let newContentId = textSystem.contentIdentity

			self.state.update(url: url, typeName: typeName, contentId: newContentId)
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
	private func stateUpdated(_ oldValue: DocumentState) {
		if oldValue == state || isClosing {
			return
		}

		logger.debug("document state changed")

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
